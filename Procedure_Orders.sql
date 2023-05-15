create or replace PACKAGE MANAGE_ORDERS AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

 

  procedure book_an_order(IN_CUSTOMER_FNAME Customer.CUSTOMER_FNAME%type,

                            IN_PRODUCT_NAME PRODUCT.product_name%TYPE,

                            IN_ord_qty number,

                            IN_INSURANCE_STATUS ORDERS.INSURANCE_STATUS%type

                           );

                          

   procedure cancel_an_order(

                                 IN_orders_id number,

                                 IN_product_name PRODUCT.product_name%TYPE,

                                 In_cancelation_qty number --if null cancel in full quantities

                                 );

    procedure DROP_record_orders (IN_orders_ID orders.orders_ID%type );

        

 

END MANAGE_ORDERS;

/

create or replace PACKAGE BODY MANAGE_ORDERS AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

 

  procedure book_an_order(IN_CUSTOMER_FNAME Customer.CUSTOMER_FNAME%type,

                            IN_PRODUCT_NAME PRODUCT.product_name%TYPE,

                            IN_ord_qty number,

                            IN_INSURANCE_STATUS ORDERS.INSURANCE_STATUS%type

                           )

 

is

out_of_stock exception;

invalid_CUSTOMER_FNAME exception;

invalid_product_name exception;

invalid_ord_qty exception;

incvalid_INSURANCE_STATUS exception;

v_remaining_qty number;

CURSOR c_productname is

      select product_name FROM  product;

CURSOR c_customername is

      select customer_fname, customer_category_ID FROM  customer;

v_product_name varchar(100);

v_customer_name varchar(100);

v_customer_category_ID number;

IS_PRD_TRUE number := 0;

IS_CUST_TRUE number := 0;

pid PRODUCT.product_id%type;

v_oid orders.orders_id%type;

v_ins_price INSURANCE_PRICE.INSURANCE_PRICE_ID%type;

v_ord_price number;

 

begin

 

    

OPEN c_productname;

   LOOP

   FETCH c_productname into v_product_name;

      EXIT WHEN c_productname%notfound;  

if (v_product_name =  IN_product_NAME)

then

dbms_output.put_line ('it has come inside product loop');

select available_quantity

    into v_remaining_qty

    from INVENTORY_STATUS

    where product_id = (select x.product_id from product x where trim(lower(x.product_name))=trim(lower(IN_PRODUCT_NAME)));

 

IS_PRD_TRUE := 1;

exit;

end if;

end loop;

close c_productname;

 

OPEN c_customername;

   LOOP

   FETCH c_customername into v_customer_name,v_customer_category_ID;

      EXIT WHEN c_customername%notfound;  

if (v_customer_name =  IN_CUSTOMER_FNAME)

then

dbms_output.put_line ('it has come inside customer loop');

IS_CUST_TRUE := 1;

exit;

end if;

end loop;

close c_customername;

 

if (length(IN_PRODUCT_NAME) <=0 or IS_PRD_TRUE = 0)

      then

         raise invalid_product_name;

elsif  (length(IN_CUSTOMER_FNAME) <= 0 or IS_CUST_TRUE = 0)

      then

          raise invalid_CUSTOMER_FNAME;

elsif length(IN_INSURANCE_STATUS) <= 0

then raise incvalid_INSURANCE_STATUS ;       

elsif IN_ord_qty > v_remaining_qty

    then

    --dbms_output.put_line('not of inventory error');

    raise out_of_stock;

else

    v_ord_price := get_total_order_price(IN_ord_qty,IN_INSURANCE_STATUS,IN_PRODUCT_NAME,v_customer_category_ID);

    dbms_output.put_line('insert orders');  

    insert into ORDERS

    (ORDERS_ID,

    CUSTOMER_ID,

    PRODUCT_ID,

    WARRANTY_ID,

    OFFER_ID,

    ORDER_DATE,

    DISPATCH_DATE,

    ORDER_PRICE,

   -- DELETED_ORDER,

    PAY_STATUS,

    ORDER_QTY,

   -- DELETE_QTY,

    INSURANCE_STATUS

    )

    values

    (ORDER_seq.nextval,

    (select customer_ID from customer where lower(trim(customer.customer_fname)) = lower(trim(IN_CUSTOMER_FNAME))),

    (select PRODUCT_ID from PRODUCT where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME))),

     war_seq.nextval,

        (

select offer_ID

from offers

inner join customer_category

on offers.customer_category_ID = customer_category.customer_category_id

inner join customer on

customer.customer_category_id = customer_category.customer_category_id

where lower(trim(customer_fname)) = lower(trim(IN_CUSTOMER_FNAME))),

        sysdate,

        sysdate+2,

        v_ord_price,

'Y',IN_ord_qty,IN_INSURANCE_STATUS);

 

update product

set qty_per_unit = qty_per_unit - IN_ord_qty

where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));

 

select PRODUCT_ID into pid from PRODUCT where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));

v_oid := ORDER_seq.currval;

MANAGE_WARRANTY.add_new_WARRANTY(pid,v_oid,sysdate,add_months(sysdate,3));

MANAGE_COURIER.add_new_COURIER(v_oid,'UPS','In Transit','Y');

 

select Insurance_price_id into v_ins_price from INSURANCE_PRICE where product_id = pid  ;

    dbms_output.put_line(length(pid)||pid);

 if IN_INSURANCE_STATUS = 'Y'

then MANAGE_INSURANCE.add_new_INSURANCE(sysdate,add_months(sysdate,12),v_oid,v_ins_price);

end if;

 

  

end if;

commit;

 

exception

when out_of_stock

then dbms_output.put_line('Required product is not available in stock or cannot fullfil the order for palced quantity');

when invalid_product_name

then dbms_output.put_line('Please enter correct product name');

when invalid_CUSTOMER_FNAME

then dbms_output.put_line('Please enter correct value for customer first name');

when incvalid_INSURANCE_STATUS

then dbms_output.put_line('Please update insurance status with Y or N');

when others

then dbms_output.put_line(sqlerrm);

end book_an_order;

 

procedure cancel_an_order(

                                 IN_orders_id number,

                                 IN_product_name PRODUCT.product_name%TYPE,

                                 In_cancelation_qty number

                                 )        

is

invalid_product_name exception;

invalid_cancelation_Qty exception;

invalid_order_id exception;

v_customer_category_ID number;

v_offer_ID number;

v_insurance_status varchar(3);

CURSOR c_orderdetail is

      select p.product_name, o.orders_ID,o.ORDER_QTY,cc.customer_category_ID,o.offer_ID,o.insurance_status

      from  product p join orders o

      on p.product_ID = o.Product_ID

      join customer c

      on c.customer_ID = o.customer_ID

      join customer_category cc

      on c.customer_category_ID = cc.customer_category_ID;

v_product_name PRODUCT.product_name%TYPE;

v_orders_ID number;

IS_PRD_TRUE number:=0;

IS_ORD_True number:=0;

v_ord_qty  number:=0;

cancelled_ord_price number:=0;

v_can_ord_qty number:=0;

begin

     

OPEN c_orderdetail;

   LOOP

   FETCH c_orderdetail into v_product_name,v_orders_ID,v_ord_qty,v_customer_category_ID,v_offer_ID,v_insurance_status;

      EXIT WHEN c_orderdetail%notfound;  

if (v_product_name =  IN_product_NAME)

then

dbms_output.put_line ('it has come inside orderdetail prd loop');

IS_PRD_TRUE := 1;

end if;

if ( v_orders_ID = IN_orders_id)

then

dbms_output.put_line ('it has come inside orderdetail ord loop');

IS_ORD_TRUE := 1;

exit;

end if;

end loop;

close c_orderdetail;

 

if (length(IN_PRODUCT_NAME) <=0 or IS_PRD_TRUE = 0)

      then

         raise invalid_product_name;

elsif  (IN_orders_id <= 0 or IS_ORD_TRUE = 0)

      then

          raise invalid_Order_ID;

elsif (  v_ord_qty < In_cancelation_qty)

then  raise invalid_cancelation_Qty;

end if;

 

cancelled_ord_price := get_total_order_price(In_cancelation_qty,v_insurance_status,v_product_name,v_customer_category_ID);

 

select (order_qty-In_cancelation_qty) into v_can_ord_qty

from orders

where orders_id = v_orders_ID;

 

if (v_can_ord_qty=0)

then

update orders

set Insurance_status= 'N',

order_qty=order_qty-In_cancelation_qty,

ORDER_PRICE = ORDER_PRICE - cancelled_ord_price

where orders_id = v_orders_ID;

execute immediate 'delete from insurance where orders_ID = '|| IN_orders_ID;

else

update orders

set order_qty=order_qty-In_cancelation_qty,

ORDER_PRICE = ORDER_PRICE - cancelled_ord_price

where orders_id = v_orders_ID;

end if;

 

if (v_can_ord_qty=0)

then

update warranty

set start_date = '',

ENd_date = ''

where orders_id = v_orders_ID;

end if;

 

update product

set QTY_PER_UNIT = QTY_PER_UNIT + In_cancelation_qty

where PRODUCT_NAME = IN_PRODUCT_NAME;

if (v_ord_qty = In_cancelation_qty)

then update courier

    set DELIVERY_STATUS = 'cancelled'

    where orders_id = v_orders_ID;

end if;

 

commit;

 

dbms_output.put_line('order#' || IN_orders_id || 'is updated');

 

exception

when invalid_order_id

then dbms_output.put_line('OrderID ' ||IN_orders_id|| ' not found');

when invalid_product_name

then dbms_output.put_line('Please enter correct product name');

when invalid_cancelation_Qty

then dbms_output.put_line('entered quantity exceeds ordered quantity');

when others

then dbms_output.put_line(sqlerrm);

end cancel_an_order;

 

procedure DROP_record_orders (IN_orders_ID orders.orders_ID%type )

as

cid number ;

IS_TRUE  number;

invalid_IN_orders_ID exception;

Object_not_found exception;

CURSOR c_ordersid is

      select orders_ID FROM  orders; --where  lower(object_name) = 'abcd'    ;

 

begin

if IN_orders_ID <=0

      then

          raise invalid_IN_orders_ID;      

    end if;

           

   IS_TRUE:= 0;    

OPEN c_ordersid;

   LOOP

   FETCH c_ordersid into cid;

      EXIT WHEN c_ordersid%notfound;  

if (cid =  IN_orders_ID)

then

dbms_output.put_line ('it has come inside loop');

execute immediate 'delete from orders where orders_ID = '|| IN_orders_ID;

dbms_output.put_line(IN_orders_ID || ' is deleted' );

IS_TRUE := 1;

end if;

end loop;

close c_ordersid;

 

if IS_TRUE = 0 then raise Object_not_found ;

   end if;

 

exception

when invalid_IN_orders_ID

then dbms_output.put_line ('Please enter valid orders_ID');

when Object_not_found

then dbms_output.put_line (IN_orders_ID || ' order id not found');

when others

then dbms_output.put_line(sqlerrm);

 

end DROP_record_orders;

 

END MANAGE_ORDERS;

 

 

/