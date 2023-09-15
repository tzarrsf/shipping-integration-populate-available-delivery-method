public class CheckoutShippingIntegration implements sfdc_checkout.CartShippingCharges {
    public sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        System.debug('IM FROM INTEGRATION HELLO THEREJk');
        sfdc_checkout.IntegrationStatus result = new sfdc_checkout.IntegrationStatus();
        Id deliveryChargeId = [SELECT Id FROM Product2 WHERE Name = 'DELIVERY_CHARGE' AND IsActive = TRUE LIMIT 1]?.Id;
        if(deliveryChargeId == null) {
            result.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        } else {
            CartDeliveryGroup cartDeliveryGroup = [SELECT Id, DeliveryMethodId FROM CartDeliveryGroup WHERE CartId = :cartId][0];
            List<OrderDeliveryMethod> odms = [SELECT Id FROM OrderDeliveryMethod WHERE IsActive = TRUE AND ProductId = :deliveryChargeId];
            cartDeliveryGroup.DeliveryMethodId =  odms[0].Id;
            update cartDeliveryGroup;
           
            //SALESFORCE CHANGE STARTS
            delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroup.Id];
            
            CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
              CartDeliveryGroupId = cartDeliveryGroup.Id,
              DeliveryMethodId = cartDeliveryGroup.DeliveryMethodId,
              Name = 'Free Shipping',
              ShippingFee = 0,
              WebCartId = cartId
            );
            insert(cartDeliveryGroupMethod);

            system.debug('cartDeliveryGroupMethod>>'+cartDeliveryGroupMethod.Id);
            //SALESFORCE CHANGE ENDS
            
            result.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
        }
        return result;
    }
}
