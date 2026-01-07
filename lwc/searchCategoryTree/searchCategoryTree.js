/*
 * Copyright (c) 2023, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 * For full license text, see the LICENSE file in the repo
 * root or https://opensource.org/licenses/apache-2-0/
 */
import { LightningElement, api, track, wire } from "lwc";
import labels from "./labels";
const EVENT = {
  CATEGORY_UPDATE_EVT: "categoryupdate"
};
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { CurrentPageReference } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getChildCategories from '@salesforce/apex/ChildCategoryProductService.getChildCategories';



/**
 * Tree node representation for a single category and its sub-categories.
 * @typedef {object} CategoryInfoTreeAncestorNode
 * @property {string} id
 *  The id of the tree node
 * @property {string} label
 *  The label of the tree node.
 * @property {string} categoryName
 *  The display name of the category, without product count included.
 * @property {string} backActionAssistiveText
 *  The label for the node back action assistive text
 */

/**
 * UI Representation for the category tree
 * @typedef {object} CategoryInfoTree
 * @property {CategoryInfoTreeNode[]} ancestorCategories
 *  The list of categories that are ancestors to the current selected category
 * @property {CategoryInfoTreeNode} selectedCategory
 *  The category that is currently selected
 */

/**
 * Tree node representation for a single category and its sub-categories.
 * @typedef {object} CategoryInfoTreeNode
 * @property {string} id
 *  The id of the tree node
 * @property {string} label
 *  The label of the tree node.
 * @property {Array<CategoryInfoTreeNode>} items
 *  The child nodes of the tree node
 */

/**
 * A event fired when the user indicates a desire to change the category.
 * @event SearchCategoryTree#categoryupdate
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} detail.categoryId
 *  The unique category identifier.
 */

/**
 * Representation for the category tree
 * @fires SearchCategoryTree#categoryupdate
 */
export default class SearchCategoryTree extends LightningElement {
  static renderMode = "light";
  categoryId;
  @track childCategories = [];
  parentCategoryName;
  isCategoryPage;
  connectedCallback() {
    console.log("SearchCategoryTree");
    console.log("_selectedCategory - ", this._selectedCategory);
    console.log("selectedCategoryItems - ", this.selectedCategoryItems);
  }

  @wire(CurrentPageReference)
  getPageRef(res) {
    if (res.type === "standard__search") {
      this.isCategoryPage = false;
    } else if (res.attributes.objectApiName === "ProductCategory") {
      this.isCategoryPage = true;
    }
    this.categoryId = res.state.category
      ? res.state.category
      : res.attributes.recordId;
  }

  @wire(getRecord, { recordId: "$categoryId", fields: "ProductCategory.Name" })
  loadParentCategoryName({ error, data }) {
    if (data) {
      this.parentCategoryName = data?.fields?.Name?.value;
    }
  }

  /**
   * Gets or sets the category tree display-data.
   * @type {?CategoryInfoTree}
   */

  @track
  _displayData;
  @api
  get displayData() {
    return this._displayData;
  }
  set displayData(value) {
    this._displayData = value;
  }

 
  @wire(getChildCategories, { parentId: '$categoryId' })
  wiredChildCategories({ error, data }) {
   if (data) {
      this.childCategories = data;
      console.log('data in getChildCategories: ', JSON.stringify(data));
    } else if (error) {
      this.childCategories = [];
      this.error = error;
      console.log('Error in getChildCategories: ', error);
    }
  }

  /**
   * The normalized / defaulted ancestor categories of the tree.
   * @type {CategoryInfoTreeAncestorNode[]}
   * @private
   */
  get _ancestorCategories() {
    return this.displayData?.ancestorCategories ?? [];
  }

  /**
   * The normalized / defaulted selected category of the tree.
   * @type {CategoryInfoTreeNode}
   * @private
   */
  get _selectedCategory() {
    return this.displayData?.selectedCategory ?? {};
  }

  /**
   * Gets the normalized list of items from the selected category.
   * @type {CategoryInfoTreeNode[]}
   * @private
   */
  get selectedCategoryItems() {
    return this._selectedCategory?.items ?? [];
  }

  /**
   * Determines whether the currently selected category is visible.
   * @type {boolean}
   * @private
   */
  get _isSelectedCategoryVisible() {
    return Object.keys(this._selectedCategory).length > 0;
  }

  /**
   * Gets the label for the category header.
   * @returns {string} the label for the category header
   * @private
   */
  get _categoryHeader() {
    return labels.categoryHeader;
  }

  /**
   * Handler for the 'click' event fired from categoryTree
   * @param {MouseEvent | KeyboardEvent} evt the event object
   * @fires SearchCategoryTree#categoryupdate
   */
  handleCategoryUpdate(evt) {
    evt.preventDefault();
    if (evt.target instanceof HTMLElement) {
      const categoryId = evt?.target?.dataset?.categoryid;
      this.dispatchEvent(
        new CustomEvent(EVENT.CATEGORY_UPDATE_EVT, {
          bubbles: true,
          composed: true,
          cancelable: true,
          detail: categoryId
        })
      );
    }
  }

  /**
   * Handle the keydown event from categoryTree
   * @param {KeyboardEvent} evt the event object
   */
  handleKeydown(evt) {
    if (evt.key === "Enter") {
      this.handleCategoryUpdate(evt);
    }
  }
}