create or replace PACKAGE MANAGE_COURIER AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

  procedure add_new_COURIER(

    IN_ORDERS_ID COURIER.ORDERS_ID%TYPE,

    IN_COURIER_NAME COURIER.COURIER_NAME%TYPE,

    IN_DELIVERY_STATUS COURIER.DELIVERY_STATUS%TYPE,

    IN_PAY_STATUS COURIER.PAY_STATUS%TYPE

    );

 

     procedure courier_delivered(

     IN_COURIER_ID courier.COURIER_ID%type

     );

   

     procedure DROP_record_courier (IN_courier_ID courier.courier_ID%type );

    

END MANAGE_COURIER;

/

create or replace PACKAGE BODY MANAGE_COURIER AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

  procedure add_new_COURIER(

    IN_ORDERS_ID COURIER.ORDERS_ID%TYPE,

    IN_COURIER_NAME COURIER.COURIER_NAME%TYPE,

    IN_DELIVERY_STATUS COURIER.DELIVERY_STATUS%TYPE,

    IN_PAY_STATUS COURIER.PAY_STATUS%TYPE    )

AS

    invalid_ORDERS_ID exception;

    invalid_COURIER_NAME exception;

    invalid_DELIVERY_STATUS exception;

    invalid_PAY_STATUS exception;

  

BEGIN

if IN_ORDERS_ID <=0

      then

         raise invalid_ORDERS_ID;

  elsif  length(IN_COURIER_NAME) <= 0

      then

          raise invalid_COURIER_NAME;

  elsif  length(IN_DELIVERY_STATUS) <= 0

      then

          raise invalid_DELIVERY_STATUS;

  elsif  length(IN_PAY_STATUS) <= 0

      then

          raise invalid_PAY_STATUS;

   

    end if;

 

Insert into COURIER (

   COURIER_ID,

    ORDERS_ID,

    COURIER_NAME,

    DELIVERY_STATUS ,

    PAY_STATUS

)

values(

    courier_seq.nextval,

    IN_ORDERS_ID,

    IN_COURIER_NAME,

    IN_DELIVERY_STATUS ,

    IN_PAY_STATUS

);

commit;

 

exception

when invalid_ORDERS_ID

then

    dbms_output.put_line('Please enter correct BILL NUMBER');

when invalid_COURIER_NAME

then

    dbms_output.put_line('Please enter correct COURIER NAME');

when invalid_DELIVERY_STATUS

then

    dbms_output.put_line('Please enter correct y or n for DELIVERY STATUS');

when invalid_PAY_STATUS

then

    dbms_output.put_line('Please enter correct y or n for PAY STATUS');

when others

then dbms_output.put_line('Please enter correct values in COURIER Table');

END add_new_COURIER;

 

procedure courier_delivered(

     IN_COURIER_ID courier.COURIER_ID%type

     )

as

 

v_courier_ID number := 0;

Invalid_courier_ID exception;

cursor c_courier is

        select courier_id from courier;

IS_Courier_TRUE number :=0;

v_product_name varchar(100);

v_ordes_ID number;

BEGIN

 

--select courier_id into v_courier_ID from courier where courier_id = IN_COURIER_ID;

 

OPEN c_courier;

   LOOP

   FETCH c_courier into v_courier_ID;

      EXIT WHEN c_courier%notfound;

if (v_courier_ID = IN_COURIER_ID)

then

dbms_output.put_line ('it has come inside courier loop');

IS_Courier_TRUE := 1;

EXIT;

end if;

end loop;

close c_courier;

 

 

 

if(v_courier_ID <> IN_COURIER_ID)

then raise Invalid_courier_ID;

else

select product_name, o.orders_ID into v_product_name,v_ordes_ID

from courier c join orders o

on c.orders_ID = o.orders_id

join product p

on o.product_ID = p.product_ID

where c.courier_ID = IN_COURIER_ID  ;

update courier

set delivery_status = 'Delivered'

where courier_id = IN_COURIER_ID ;

dbms_output.put_line(v_product_name || ' is delivered for order#' ||v_ordes_ID);

end if;

 

commit;

 

EXCEPTION

when Invalid_courier_ID

then dbms_output.put_line('Enter correct courier ID');

when others

then dbms_output.put_line(sqlerrm);

 

END courier_delivered;

 

procedure DROP_record_courier (IN_courier_ID courier.courier_ID%type )

as

cid number ;

IS_TRUE  number;

invalid_IN_courier_ID exception;

Object_not_found exception;

CURSOR c_courierid is

      select courier_id FROM  courier; --where  lower(object_name) = 'abcd'    ;

 

begin

if IN_courier_ID <=0

      then

          raise invalid_IN_courier_ID;     

    end if;

           

   IS_TRUE:= 0;    

OPEN c_courierid;

   LOOP

   FETCH c_courierid into cid;

      EXIT WHEN c_courierid%notfound;  

if (cid =  IN_courier_ID)

then

dbms_output.put_line ('it has come inside loop');

execute immediate 'delete from courier where courier_ID = '|| IN_courier_ID;

dbms_output.put_line(IN_courier_ID || ' is deleted' );

IS_TRUE := 1;

end if;

end loop;

close c_courierid;

 

if IS_TRUE = 0 then raise Object_not_found ;

   end if;

 

exception

when invalid_IN_courier_ID

then dbms_output.put_line ('Please enter valid courier_ID');

when Object_not_found

then dbms_output.put_line (IN_courier_ID || ' cid not found');

when others

then dbms_output.put_line(sqlerrm);

 

end DROP_record_courier;

 

END MANAGE_COURIER;

/

 
