import { LightningElement, api, wire } from "lwc";

import getColumnInfos from "@salesforce/apex/ListDataService.getColumnInfos";
import queryRecordsByIds from "@salesforce/apex/ListDataService.queryRecordsByIds";
import { getColumnTypeAttributes, getColumnType, getRows } from "./listUtils";
import { throwConfigurationError, throwRuntimeError } from "c/errorService";

import MessageService from "c/messageService";

export default class List extends LightningElement {
  /*
   *  Public Properties
   */
  @api objectApiName;
  @api fieldApiNames;
  @api componentId = "LIST_CMP";
  @api sourceComponentIds = "SEARCH_CMP,FILTER_CMP";
  @api targetComponentIds = "0";
  @api sortBy = "Id";
  @api sortDirection = "asc";
  @api tableHeight = 500;
  @api hideCheckboxColumn;
  @api get pageSize() {
    return this._pageSize || 10;
  }
  set pageSize(value) {
    this._pageSize = parseInt(value, 10);
    this.setAttribute("pageSize", this._pageSize);
  }
  @api reload() {
    this.pageIndex = 0;
    this.loadData();
  }
  /*
   *  Private Properties
   */
  recordIds;
  fieldInfos;
  columns = [];
  data = [];
  selectedRows;
  sortedBy;
  sortedDirection;
  pageIndex = 0;
  showSpinner = false;
  get tableWrapperStyle() {
    return "height:" + this.tableHeight + "px;";
  }

  /*
   *  Wired Properties and Functions
   */
  @wire(getColumnInfos, {
    objectApiName: "$objectApiName",
    fieldApiNames: "$fieldApiNames"
  })
  wiredGetColumnInfos({ error, data }) {
    if (data && !data.hasError) {
      const columnInfos = data.body;
      this.columns = columnInfos.map((columnInfo) => {
        return {
          label: columnInfo.label,
          fieldName: columnInfo.name,
          type: getColumnType(columnInfo),
          sortable: columnInfo.isSortable,
          typeAttributes: getColumnTypeAttributes(columnInfo)
        };
      });
    } else if (data && data.hasError) {
      throwConfigurationError(data.errorMessage, data.errorCode);
    } else if (error) {
      throwConfigurationError(error);
    }
  }

  /*
   *  UI Event Handlers
   */
  onColumnSorted(e) {
    this.sortedBy = e.detail.fieldName;
    this.sortedDirection = e.detail.sortDirection;
    this.pageIndex = 0;
    this.loadData();
  }
  onLoadMore() {
    const hasNext = this.recordIds.length > this.pageIndex * this.pageSize;
    if (hasNext) {
      this.pageIndex++;
      this.loadData();
    }
  }
  onRowSelection(e) {
    this.dispatchEvent(
      new CustomEvent("rowselected", {
        detail: { selectedRows: e.detail.selectedRows }
      })
    );
  }

  /*
   *  Lifecycle Event Handlers
   */
  connectedCallback() {
    this.messageService = new MessageService(this, this.targetComponentIds);
    this.messageService.subscribeStatusChangedToCompleted(
      this.onStatusChangedToCompleted.bind(this)
    );

    // Init properties
    this.sortedBy = this.sortBy;
    this.sortedDirection = this.sortDirection;
  }
  disconnectedCallback() {
    this.messageService.unsubscribeAll();
  }
  renderedCallback() {
    if (!this.isRendered) {
      this.isRendered = true;
      this.messageService.publishStatusChangedToReady();
    }
  }

  onStatusChangedToCompleted({ data, errors }) {
    if (errors) {
      throwRuntimeError(errors);
      return;
    }
    this.recordIds = data;
    this.pageIndex = 0;
    this.loadData();
  }
  /*
   *  Helper Functions
   */
  loadData() {
    this.showSpinner = true;
    const params = {
      objectApiName: this.objectApiName,
      fieldApiNames: this.fieldApiNames,
      recordIds: this.recordIds.join(","),
      sortedBy: this.sortedBy,
      sortedDirection: this.sortedDirection,
      pageSize: this.pageSize,
      pageIndex: this.pageIndex
    };
    queryRecordsByIds(params)
      .then((data) => {
        if (data && !data.hasError) {
          if (params.pageIndex === 0) {
            this.data = getRows(data.body, this.columns);
          } else {
            this.data = this.data.concat(getRows(data.body, this.columns));
          }
          this.showSpinner = false;
        } else if (data && data.hasError) {
          throwRuntimeError(data.errorMessage, data.errorCode);
        }

        this.dispatchEvent(
          new CustomEvent("load", {
            detail: {
              numberOfRecords: this.data.length,
              totalNumberOfRecords:
                this.recordIds.length > 0 ? this.recordIds.split(",").length : 0
            }
          })
        );
      })
      .catch((error) => {
        this.error = error;
        this.showSpinner = false;
      });
  }
}
