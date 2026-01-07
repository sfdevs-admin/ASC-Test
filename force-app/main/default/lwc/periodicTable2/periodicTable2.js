/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 30-06-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, wire } from "lwc";
import {
  CurrentPageReference,
  navigate,
  NavigationContext
} from "lightning/navigation";
import getProductCategory from "@salesforce/apex/B2B_PeriodicTableController.getProductCategory";
import b2bSiteCategoryUrl from "@salesforce/label/c.b2bSiteCategoryUrl";
import B2B_ParentCategoryId from "@salesforce/label/c.B2B_ParentCategoryId";

export default class PeriodicTable2 extends LightningElement {
  static renderMode = "light";
  searchTerm = null;

  @wire(NavigationContext)
  navContext;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.searchTerm = currentPageReference?.state?.term
        ? currentPageReference.state.term
        : null;
    }
  }
  messageState = "Please Wait";
  showSpinner = false;

  async handleNavigation(event) {
    let element = event.currentTarget.dataset.element;
    console.log("handleNavigation----- " + element);
    if (element && element != "") {
      this.showSpinner = true;
      //do apex call to get the category Id.
      let mapParams = {};
      mapParams.elementVal = element;
      await getProductCategory({
        mapParams: mapParams
      })
        .then((res) => {
          let response = JSON.parse(JSON.stringify(res));
          console.log(
            "PeriodicTable callgetProductCategory res---- ",
            response
          );
          if (res.isSuccess) {
            // this.showSpinner = false;
            this.goToCategory(response.elementsList[0]);
          } else {
            //show no data found error
            this.showSpinner = false;
            console.log(
              "PeriodicTable callgetProductCategory is success false---- " +
                JSON.stringify(res)
            );
          }
        })
        .catch((e) => {
          this.showSpinner = false;
          console.log(
            "PeriodicTable callgetProductCategory catch---- " +
              JSON.stringify(e)
          );
        });
    }
  }

  goToCategory(e) {
    let catId = e.Category_Id__c;
    let catName = e.Name;

    if (catId) {
      let url =
        b2bSiteCategoryUrl +
        B2B_ParentCategoryId +
        "?periodicTable=true&catName=" +
        encodeURIComponent(catName);
      window.location.href = url;

      let tempThis = this;
      setTimeout(() => {
        tempThis.showSpinner = false;
      }, 2000);
    }
  }

  async handleNavigation2(event) {
    let element = event.currentTarget.dataset.element;
    console.log("handleNavigation2----- " + element);
    if (element && element != "") {
      this.showSpinner = true;
      //do apex call to get the category Id.
      let mapParams = {};
      mapParams.elementVal = element;
      await getProductCategory({
        mapParams: mapParams
      })
        .then((res) => {
          let response = JSON.parse(JSON.stringify(res));
          console.log(
            "PeriodicTable callgetProductCategory res---- ",
            response
          );
          if (res.isSuccess) {
            // this.showSpinner = false;
            this.goToCategoryStandard(response.elementsList[0]);
          } else {
            //show no data found error
            this.showSpinner = false;
            console.log(
              "PeriodicTable callgetProductCategory is success false---- " +
                JSON.stringify(res)
            );
          }
        })
        .catch((e) => {
          this.showSpinner = false;
          console.log(
            "PeriodicTable callgetProductCategory catch---- " +
              JSON.stringify(e)
          );
        });
    }
  }

  goToCategoryStandard(e) {
    let catId = e.Category_Id__c;
    let catName = e.Name;
    if (catId) {
      let url = b2bSiteCategoryUrl + catId + "?periodicTable=true";
      window.location.href = url;
      let tempThis = this;
      setTimeout(() => {
        tempThis.showSpinner = false;
      }, 2000);
    }
  }
}