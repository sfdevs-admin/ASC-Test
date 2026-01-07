import { LightningElement, track, api, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
// import createContentVers from '@salesforce/apex/B2B_EnhancedFileUploaderController.createContentVers';
// import appendDataToContentVersion from '@salesforce/apex/B2B_EnhancedFileUploaderController.appendDataToContentVersion';
import createContentDocLink from '@salesforce/apex/B2B_EnhancedFileUploaderController.createContentDocLink';
import deleteContentDoc from '@salesforce/apex/B2B_EnhancedFileUploaderController.deleteContentDoc';
import getExistingFiles from '@salesforce/apex/B2B_EnhancedFileUploaderController.getExistingFiles';
import updateFileName from '@salesforce/apex/B2B_EnhancedFileUploaderController.updateFileName';
import MAIN_TEMPLATE from "./b2bEnhancedFileUploader.html";
import STENCIL from "./b2bEnhancedFileUploaderStencil.html";
import Toast from 'lightning/toast';
// import deleteAllContentDoc from '@salesforce/apex/B2B_EnhancedFileUploaderController.deleteAllContentDoc';

const MAX_FILE_SIZE = 4500000;
const CHUNK_SIZE = 750000;

// Convert CB values to a boolean
function cbToBool(value) {
    console.log('cb to bool value  -->', value);
    return value === "CB_TRUE";
  }

export default class B2bEnhancedFileUploader extends NavigationMixin(LightningElement) {
    static renderMode = 'light';
    
    render() {
        // return MAIN_TEMPLATE;
        if(this.loading){
            return STENCIL;
        }else{
            return MAIN_TEMPLATE;
        }
    }

    @api acceptedFormats;
    @api
    get allowMultiple() {
    return cbToBool(this.cb_allowMultiple);
    }
    @api cb_allowMultiple;
    @api community; // deprecated
    @api communityDetails; // deprecated
    @api contentDocumentIds;
    @api contentVersionIds;
    @api
    get disableDelete() {
    return cbToBool(this.cb_disableDelete);
    }
    @api cb_disableDelete;
    @api
    get embedExternally() {
    return cbToBool(this.cb_embedExternally);
    }
    @api cb_embedExternally;
    @api helpText;
    @api icon;
    @api label;
    @api overriddenFileName;    

    _recordId
    @api get recordId(){
        return this._recordId;
    }
    set recordId(value){
        if( value ){
            this._recordId = value;
            // this.fetchExistingFiles();
        }
    }

    renderExistingFiles = true;
    // @api 
    // get renderExistingFiles() {
    //     return cbToBool(this.cb_renderExistingFiles);
    // }
    @api cb_renderExistingFiles;
    @api
    get renderFilesBelow() {
    return cbToBool(this.cb_renderFilesBelow);
    }
    @api cb_renderFilesBelow;
    @api
    get required() {
    return cbToBool(this.cb_required);
    }
    @api cb_required;
    @api requiredMessage;
    @api sessionKey;
    @api uploadedFileNames;
    @api uploadedlabel;
    @api uploadedLabel; // deprecated
    @api
    get visibleToAllUsers() {
    return cbToBool(this.cb_visibleToAllUsers);
    }
    @api cb_visibleToAllUsers;
    
    @track docIds =[];
    @track fileNames = [];
    @track objFiles = [];
    @track versIds = [];

    get bottom(){
        if(this.renderFilesBelow){
            return true;
        }
        else{
            return false;
        }
    }

    get external(){
        if(this.embedExternally){
            return true;
        }
        else{
            return false;
        }
    }

    cartId;
    @api 
    get currentCartId(){
        return this.cartId;
    }
    set currentCartId(value){
        if( value ){
            this.cartId = value;
            this.fetchExistingFiles();
        }
    }

    fetchExistingFiles() {
        this.loading = false;
        console.log('inside fetchExistingFiles--- ', this.cartId, this.renderExistingFiles);
        if(this.cartId && this.renderExistingFiles) {
            let mapParams = {};
            mapParams.recordId = this.cartId;

            getExistingFiles({mapParams: mapParams})
                .then((result) => {
                    console.log('result of existing files--> ', result);
                    if(result.files != undefined && result.files.length > 0){
                        this.processFiles(result.files);
                    } else {
                        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
                    }
                })
                .catch((error) => {
                    this.showErrors(this.reduceErrors(error).toString());
                })
        } else {
            this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
        }
    }

    connectedCallback(){
    }

    numberOfFilesToUpload = 0;
    loading = true;

    handleUpload_lightningFile(event){
        console.log('## call - handleUploadFinished()');
        let files = event.detail.files;
        this.handleUploadFinished(files);
    }
    
    handleUploadFinished(files) {
        console.log('## call 2  - handleUploadFinished()', files);

        let objFiles = [];
        let versIds = [];
        files.forEach(file => {
            let name;
            if(this.overriddenFileName){
                name = this.overriddenFileName.substring(0,255) +'.'+ file.name.split('.').pop();
            } else {
                name = file.name;
            }
            
            let objFile = {
                name: name,
                documentId: file.documentId,
                contentVersionId: file.contentVersionId
            }
            objFiles.push(objFile);

            versIds.push(file.contentVersionId);
        })

        if(this.overriddenFileName){
            let mapParams = {};
            mapParams.versIds = versIds;
            mapParams.fileName = this.overriddenFileName.substring(0,255)
            
            updateFileName({mapParams : mapParams})
                .catch(error => {
                    this.showErrors(this.reduceErrors(error).toString());
                });
        }
        
        if(this.cartId && versIds.length > 0){
            console.log('## IF handleUploadFinished--- > ');
            let mapParams = {};
            mapParams.versIds = versIds;
            mapParams.encodedKey = this.currentCartId;
            mapParams.visibleToAllUsers =  this.visibleToAllUsers;

            createContentDocLink({mapParams: mapParams})
                .then((res) => {
                    this.showSuccess('All Files uploaded successfully.',versIds);
                })
                .catch(error => {
                    this.showErrors(this.reduceErrors(error).toString(),versIds);
                });
        }

        this.processFiles(objFiles);
    }

    processFiles(files){
        
        files.forEach(file => {
            let filetype;
            if(this.icon == null){
                filetype = getIconSpecs(file.name.split('.').pop());
            }
            else{
                filetype = this.icon;
            }
            let objFile = {
                name: file.name,
                filetype: filetype,
                documentId: file.documentId,
                contentVersionId: file.contentVersionId
            };
            this.objFiles.push(objFile);
            this.docIds.push(file.documentId);
            this.versIds.push(file.contentVersionId);
            this.fileNames.push(file.name);
        });

        this.checkDisabled();

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);

        function getIconSpecs(docType){
            switch(docType){
                case 'csv':
                    return 'doctype:csv';
                case 'pdf':
                    return 'doctype:pdf';
                case 'pps':
                case 'ppt':
                case 'pptx':
                    return 'doctype:ppt';
                case 'xls':
                case 'xlsx':
                    return 'doctype:excel';
                case 'doc':
                case 'docx':
                    return 'doctype:word';
                case 'txt':
                    return 'doctype:txt';
                case 'png':
                case 'jpeg':
                case 'jpg':
                case 'gif':
                    return 'doctype:image';
                default:
                    return 'doctype:unknown';
            }
        }
    }
    
    deleteDocument(event){
        this.loading = true;
        event.target.blur();

        let contentVersionId = event.target.dataset.contentversionid;    

        if(this.disableDelete){
            this.removeFileFromUi(contentVersionId);
        } else {
            let mapParams = {};
            mapParams.versId = contentVersionId;

            deleteContentDoc({mapParams: mapParams})
            .then(() => {
                this.removeFileFromUi(contentVersionId);
            })
            .catch((error) => {
                this.showErrors(this.reduceErrors(error).toString());
                this.loading = false;
            })
        }
        
    }

    removeFileFromUi(contentVersionId){
        let objFiles = this.objFiles;
        let removeIndex;
        for(let i=0; i<objFiles.length; i++){
            if(contentVersionId === objFiles[i].contentVersionId){
                removeIndex = i;
            }
        }

        this.objFiles.splice(removeIndex,1);
        this.docIds.splice(removeIndex,1);
        this.versIds.splice(removeIndex,1);
        this.fileNames.splice(removeIndex,1);

        this.checkDisabled();

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);

        this.loading = false;
    }

    disabled = false;
    checkDisabled(){
        if(!this.allowMultiple && this.objFiles.length >= 1){
            this.disabled = true;
        } else {
            this.disabled = false;
        }
    }

    communicateEvent(docIds, versIds, fileNames, objFiles){
        console.log('## communicateEvent---> ', docIds, versIds, fileNames, objFiles);

        this.dispatchEvent(new FlowAttributeChangeEvent('contentDocumentIds', [...docIds]));
        this.dispatchEvent(new FlowAttributeChangeEvent('contentVersionIds', [...versIds]));
        this.dispatchEvent(new FlowAttributeChangeEvent('uploadedFileNames', [...fileNames]));
        // this.dispatchEvent(new CustomEvent('fileupload', {bubbles: true, composed: true,detail: fileName}));
        this.loading = false;
        // sessionStorage.setItem(this.sessionKey, JSON.stringify(objFiles));
    }

    openFile(event) {
        let docId = event.target.dataset.docid;
        event.preventDefault();
    }

    @api
    validate(){
        if(this.docIds.length === 0 && this.required === true){ 
            let errorMessage;
            if(this.requiredMessage == null){
                errorMessage = 'Upload at least one file.';
            }
            else{
                errorMessage = this.requiredMessage;
            }
            return { 
                isValid: false,
                errorMessage: errorMessage
             }; 
        } 
        else {
            return { isValid: true };
        }
    }

    showErrors(errors){
        if(this.embedExternally){
            this.showAlert(errors);
        } else {
            this.showToast(errors);
        }
    }

    showSuccess(msg , versIds){
        this.showSuccessToast(msg);
    }

    showErrors(errors , versIds){
        if(this.embedExternally){
            this.showAlert(errors);
        } else {
            this.showToast(errors);
            this.deleteDocumentUponError(versIds);
        }
    }

    deleteDocumentUponError(versIds){
        this.loading = true; 

        let mapParams = {};
        mapParams.versIds= versIds;

        deleteAllContentDoc({mapParams: mapParams})
        .then(() => {
            versIds.forEach(versId => {
                this.removeAllFilesFromUi( versId ); 
            });
        })
        .catch((error) => {
            this.showErrors(this.reduceErrors(error).toString());
            this.loading = false;
        })
    }

    removeAllFilesFromUi(contentVersionId){
        let objFiles = this.objFiles;
        let removeIndex;
        for(let i=0; i<objFiles.length; i++){
            if(contentVersionId === objFiles[i].contentVersionId){
                removeIndex = i;
            }
        }

        this.objFiles.splice(removeIndex,1);
        this.docIds.splice(removeIndex,1);
        this.versIds.splice(removeIndex,1);
        this.fileNames.splice(removeIndex,1);

        this.checkDisabled();

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);

        this.loading = false;
    }

    showAlert(errors){
        window.alert(errors);
    }

    showToast(errors){
        Toast.show({
            label: 'Error',
            message: errors,
            variant: 'error',
            mode: 'sticky'
        });
    }

    showSuccessToast(msg){
        Toast.show({
            label: 'Success',
            message: msg,
            variant: 'success',
            mode: 'dismissible'
        });
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
    
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }

    get hasUploadedFiles() {
        return this.objFiles && this.objFiles.length > 0;
    }
}