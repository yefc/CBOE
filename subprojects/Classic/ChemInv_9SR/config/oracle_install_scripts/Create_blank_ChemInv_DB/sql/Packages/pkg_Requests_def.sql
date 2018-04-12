CREATE OR REPLACE PACKAGE "REQUESTS"
AS
	TYPE  CURSOR_TYPE IS REF CURSOR;

	FUNCTION CREATEREQUEST(
		pContainerID IN inv_requests.Container_ID_FK%Type,
		pQtyRequired IN inv_requests.Qty_Required%Type,
		pDateRequired IN Date,
		pUserID inv_requests.User_ID_FK%type,
		pDeliveryLocation inv_requests.delivery_location_id_fk%type,
		pRequestComments inv_requests.request_comments%type,
    pRequestTypeID inv_requests.request_type_id_fk%type,
    pContainerTypeID inv_requests.container_type_id_fk%type,
    pNumberContainers inv_requests.number_containers%type,
    pQuantityList inv_requests.quantity_list%type,
    pShipToName inv_requests.ship_to_name%type,
    pRequestStatusID inv_requests.request_status_id_fk%type,
    pExpenseCenter inv_requests.expense_center%TYPE
    ) RETURN inv_requests.request_ID%Type;

	FUNCTION UPDATEREQUEST(
		pRequestID IN inv_requests.request_ID%Type,
		pQtyRequired IN inv_requests.Qty_Required%Type,
		pDateRequired IN Date,
		pUserID inv_requests.User_ID_FK%type,
		pDeliveryLocation inv_requests.delivery_location_id_fk%type,
		pRequestComments inv_requests.request_comments%type,
    pContainerTypeID inv_requests.container_type_id_fk%type,
    pNumberContainers inv_requests.number_containers%type,
    pQuantityList inv_requests.quantity_list%type,
    pShipToName inv_requests.ship_to_name%type,
    pExpenseCenter inv_requests.expense_center%TYPE
    ) RETURN inv_requests.request_ID%Type;

	FUNCTION DELIVERREQUESTS(
		pRequestIDList varchar2
		) RETURN integer;

	FUNCTION DELETEREQUEST(
		pRequestID IN inv_requests.request_ID%Type) RETURN inv_requests.request_ID%Type;

	FUNCTION CANCELREQUEST(
		pRequestID IN inv_requests.request_ID%Type)
  RETURN inv_requests.request_ID%TYPE;

	FUNCTION UNDODELIVERY(
		pRequestID IN inv_requests.request_id%type)
  RETURN integer;

	PROCEDURE GETREQUEST(
		pRequestID IN inv_requests.request_ID%Type,
    pDateFormat IN VARCHAR2,
		O_RS OUT CURSOR_TYPE);
  FUNCTION GETNUMSAMPLES(
  	pRequestID inv_requests.request_id%TYPE)
  RETURN number;

  FUNCTION GETORDERSFORREQUEST(
  	pRequestID inv_requests.request_id%TYPE)
  RETURN varchar2;

	PROCEDURE GETREQUEST2(
		pContainerID IN inv_containers.container_id%Type,
  	pRequestTypeID IN inv_request_types.request_type_id%Type,
		pUserID IN inv_requests.User_ID_FK%type,
    pDateFormat IN VARCHAR2,
		O_RS OUT CURSOR_TYPE);

	PROCEDURE GETREQUESTS(
		pDeliverToLocationID IN inv_requests.delivery_location_id_fk%Type,
		pCurrentLocationID IN inv_requests.delivery_location_id_fk%Type,
		pFromDate IN varchar2,
		pToDate IN varchar2,
		pRequestComments IN inv_requests.request_comments%type,
		pUserID IN inv_requests.User_ID_FK%type,
		pContainerBarcode IN varchar2,
		pRequestType IN varchar2,
    pRequestTypeID IN inv_requests.request_type_id_fk%type,
    pRequestStatusID IN inv_requests.request_status_id_fk%type,
    pShipToName IN inv_requests.ship_to_name%type,
    pDateFormat IN VARCHAR2,
		O_RS OUT CURSOR_TYPE);

	FUNCTION APPROVEANDDECLINEREQUESTS(
		pApprovedRequestIDList varchar2,
		pDeclinedRequestIDList varchar2,
    pDeclineReasonList varchar2)
	RETURN varchar2;

 	FUNCTION CLOSEREQUESTS(
		pRequestIDList varchar2)
	RETURN varchar2;

 	FUNCTION GETSAMPLESPERCONTAINER(
  	pRequestID inv_requests.request_id%TYPE,
  	pBatchContainerIDs varchar2)
 	RETURN varchar2;

	PROCEDURE FULFILLREQUEST(
  	pRequestID inv_requests.request_id%TYPE,
  	pSampleContainerIDs varchar2);

	FUNCTION CREATEORDER(
	 	pDeliveryLocationID inv_orders.delivery_location_id_fk%TYPE,
  	pShipToName inv_orders.ship_to_name%TYPE,
	  pShippingConditions inv_orders.shipping_conditions%TYPE,
	  pSampleContainerIDs VARCHAR2,
  	pStatusID inv_container_status.container_status_id%TYPE)
 	RETURN inv_orders.order_id%TYPE;

	FUNCTION EDITORDER(
 		pOrderID inv_orders.order_id%TYPE,
 		pDeliveryLocationID inv_orders.delivery_location_id_fk%TYPE,
  	pShipToName inv_orders.ship_to_name%TYPE,
	  pShippingConditions inv_orders.shipping_conditions%TYPE,
	  pSampleContainerIDs VARCHAR2,
  	pStatusID inv_container_status.container_status_id%TYPE)
  RETURN inv_orders.order_id%TYPE;

	PROCEDURE GETORDER(
 		pOrderID inv_orders.order_id%TYPE,
  	O_RS OUT CURSOR_TYPE);

  FUNCTION SHIPORDER(
  	pOrderID inv_orders.order_id%TYPE)
  RETURN inv_orders.order_id%TYPE;

  FUNCTION SHIPORDERS(
  	pOrderIDList varchar2)
  RETURN varchar2;

	PROCEDURE GETORDERS(
		pShipToName IN inv_orders.ship_to_name%TYPE,
		pDeliveryLocationID IN inv_orders.delivery_location_id_fk%Type,
    pOrderStatusID IN inv_orders.order_status_id_fk%TYPE,
		pFromDate IN varchar2,
		pToDate IN varchar2,
		pContainerBarcode IN inv_containers.barcode%TYPE,
    pDateFormat IN VARCHAR2,
		O_RS OUT CURSOR_TYPE);

  FUNCTION RECEIVECONTAINERS(
  	pOrderID inv_orders.order_id%TYPE,
  	pContainerIDList varchar2,
    pStatusID inv_container_status.container_status_id%TYPE)
  RETURN varchar2;

  FUNCTION CANCELORDER (
  	pOrderID inv_orders.order_id%TYPE,
    pCancelReason inv_orders.cancel_reason%TYPE)
  RETURN VARCHAR2;

  FUNCTION GETNUMSHIPPEDCONTAINERS(
		pRequestID IN inv_requests.request_ID%TYPE)
	RETURN INTEGER;  

END REQUESTS;
/
show errors;