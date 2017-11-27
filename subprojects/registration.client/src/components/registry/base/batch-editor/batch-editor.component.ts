import {
  Component, Input, Output, EventEmitter, ElementRef, ViewChild,
  OnInit, OnChanges, ChangeDetectionStrategy, ChangeDetectorRef
} from '@angular/core';
import { NgRedux, select } from '@angular-redux/store';
import validationEngine from 'devextreme/ui/validation_engine';
import { IAppState, RecordDetailActions, IRecordDetail } from '../../../../redux';
import { IBatch, CBatch } from '../../../common';
import { getExceptionMessage, notify, notifyError, notifySuccess } from '../../../../common';
import { CViewGroupContainer, CRegistryRecord } from '../registry-base.types';
import { Observable } from 'rxjs/Observable';
import { Subscription } from 'rxjs/Subscription';
import * as X2JS from 'x2js';
import * as registryUtils from '../../registry.utils';


@Component({
  selector: 'reg-batch-editor',
  template: require('./batch-editor.component.html'),
  styles: [require('../registry-base.css')],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class RegBatchEditor implements OnChanges {
  @Input() viewModel: IBatch[] = [];
  private currentBatch: CBatch;
  @Input() viewConfig: CViewGroupContainer;
  @Output() onEdit = new EventEmitter<any>();
  @Output() valueUpdated: EventEmitter<any> = new EventEmitter<any>();

  private formVisible: boolean = false;
  private items: any[];
  private formData: any;
  private colCount: number = 5;

  constructor(
    private ngRedux: NgRedux<IAppState>,
    protected actions: RecordDetailActions,
    private changeDetector: ChangeDetectorRef,
    private elementRef: ElementRef
  ) {
    this.update();
  }

  ngOnChanges() {
    this.update();
  }

  protected x2jsTool() {
    return new X2JS.default({
      arrayAccessFormPaths: [
        'MultiCompoundRegistryRecord.BatchList.Batch',
        'MultiCompoundRegistryRecord.BatchList.Batch.BatchComponentList.BatchComponent',
        'MultiCompoundRegistryRecord.BatchList.Batch.BatchComponentList.BatchComponent.BatchComponentFragmentList.BatchComponentFragment',
        'MultiCompoundRegistryRecord.BatchList.Batch.IdentifierList.Identifier',
        'MultiCompoundRegistryRecord.BatchList.Batch.ProjectList.Project',
        'MultiCompoundRegistryRecord.BatchList.Batch.PropertyList.Property'
      ]
    });
  }

  protected update() {
    this.items = this.viewConfig != null ? this.viewConfig.getItems('edit') : [];
    if (this.items.find(i => i.itemType === 'group') != null) {
      this.colCount = 1;
    }
    let validItems = [];
    this.items.forEach(i => {
      if (i.itemType === 'group') {
        validItems = validItems.concat(i.items.filter(ix => !ix.itemType || ix.itemType !== 'empty'));
      } else if (i.itemType !== 'empty') {
        validItems.push(i);
      }
    });
    this.formData = {};
    validItems.forEach(i => {
      this.formData[i.dataField] = undefined;
    });
  }

  protected onValueUpdated(e) {
    this.viewConfig.getItems('edit').forEach(item => {
      let value = this.currentBatch.PropertyList.Property.find(i => i._name + 'Property' === item.dataField);
      if (value) {
        this.currentBatch.PropertyList.Property.find(i => i._name + 'Property' === item.dataField).__text = e.viewModel[item.dataField];
      } else {
        let entryInfo = this.viewConfig.getEntryInfo('edit', item.dataField);
        if (entryInfo.dataSource && entryInfo.bindingExpression) {
          let foundObject = CRegistryRecord.findBoundObject(entryInfo.dataSource, entryInfo.bindingExpression, true);
          if (foundObject.property) {
            this.currentBatch[foundObject.property] = e.viewModel[item.dataField];
          }
        }
      }
    });
  }

  protected showForm(e) {
    this.currentBatch = this.viewConfig.subArray[this.viewConfig.subIndex];
    this.viewConfig.getItems('edit').forEach(item => {
      let value = this.viewModel[this.viewConfig.subIndex].PropertyList.Property.find(i => i._name + 'Property' === item.dataField);
      if (value) {
        this.formData[value._name + 'Property'] = value.__text;
      } else {
        let entryInfo = this.viewConfig.getEntryInfo('edit', item.dataField);
        if (entryInfo.dataSource && entryInfo.bindingExpression) {
          let foundObject = CRegistryRecord.findBoundObject(entryInfo.dataSource, entryInfo.bindingExpression, true);
          if (foundObject.property) {
            this.formData[item.dataField] = this.viewModel[this.viewConfig.subIndex][foundObject.property];
          }
        }
      }
    });
    this.formVisible = true;
    this.changeDetector.markForCheck();
  }

  protected editBatch(e) {
    if (this.validate().isValid) {
      this.formVisible = false;
      let recordJson: any = this.x2jsTool().js2xml(this.currentBatch);
      this.onEdit.emit({ 'data': `<BatchList><Batch>` + recordJson + `</Batch></BatchList>` });
    }
  }

  validate() {
    let result = validationEngine.validateGroup('vg');
    return result;
  }

  protected cancel(e) {
    this.formVisible = false;
  }
};
