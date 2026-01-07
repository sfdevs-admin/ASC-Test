import { api, LightningElement, wire } from 'lwc';
import Id from '@salesforce/user/Id';

export default class B2bCheckoutFileUpload extends LightningElement {

    userId = Id;
    _checkoutDetails;
    @api
    get checkoutDetails() {
        return this._checkoutDetails;
    }
    set checkoutDetails(value) {
        if( value ){
            console.log('B2bCheckoutFileUpload checkoutDetails--- ', value);
            this._checkoutDetails = value;
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg','.xls', '.xlsx', '.txt', '.csv'];
    }

    get labelVal() {    
        return 'Upload File';
    }

    get fileNameOverrideVal() {
        if( this.checkoutDetails?.cartSummary?.cartId ){
            let retVal = this.checkoutDetails.cartSummary.cartId;
            return retVal;
        }
    }

    get currentCartId (){
        if( this.checkoutDetails?.cartSummary?.cartId ){
            let retVal = this.checkoutDetails.cartSummary.cartId;
            return retVal;
        }
    }

    get isRequiredVal() {
        return false;
    }

    get fileSizeLimitVal() {
        return 1000000;
    }

    get helpTextVal() {   
        return 'Upload a file';
    }

    get isUploadDisabledVal() {
        return false;
    }

    get allowMultiple(){
        return "CB_TRUE";
    }

    get renderExistingFilesVal() {
        // return true;
        return "CB_TRUE";
    }

    get requiredMessageVal (){
        return 'Upload at least one file';
    }
}