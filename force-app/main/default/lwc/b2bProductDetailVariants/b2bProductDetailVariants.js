/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 02-01-2026
 * @last modified by  : Mradul Maheshwari
**/
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, navigationContext, navigate, CurrentPageReference } from 'lightning/navigation';
import { ProductAdapter, ProductCategoryAdapter } from 'commerce/productApi';

export default class B2bProductDetailVariants extends NavigationMixin(LightningElement) {
    static renderMode = "light"; // the default is 'shadow'
    productId;
    productClass;
    variationInfoList;
    showView = false;
    parentProductId;

    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('CurrentPageReference res------- '+JSON.stringify(res));
        this.productId = res.attributes.recordId;
    }

    @wire(ProductAdapter,{productId: '$productId'})
    getProductDetails(result){
        if(result.data){
            console.log('getProductDetails result------- '+result.data);
            this.productClass = result.data.productClass;
            let data = JSON.parse(JSON.stringify(result.data.variationInfo.attributesToProductMappings));
            // data.sort((a, b) => {
            //     console.log('sorting a--- '+a);
            //     console.log('sorting b--- '+b);
            //     b.canonicalKey - a.canonicalKey;
            // });
  
            if( this.productClass == 'VariationParent' ){
                this.variationInfoList = data;
                this.showView = true;
            }else if( this.productClass == 'Variation' ){
                this.variationInfoList = data;
                this.showView = true;
                this.parentProductId = result.data.variationParentId;
            }
        }
    }

}