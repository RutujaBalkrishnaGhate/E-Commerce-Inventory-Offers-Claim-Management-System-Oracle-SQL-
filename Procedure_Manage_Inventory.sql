create or replace PACKAGE MANAGE_INVENTORY AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

procedure add_new_PRODUCT_CATEGORY(

    IN_PRODUCT_CATEGORY_DESC PRODUCT_CATEGORY.PRODUCT_CATEGORY_DESC%TYPE

    );

procedure add_new_product(

    IN_PRODUCT_NAME PRODUCT.PRODUCT_NAME%TYPE,

    IN_PRODUCT_CATEGORY_ID PRODUCT.PRODUCT_CATEGORY_ID%TYPE,

    IN_qty_per_unit PRODUCT.qty_per_unit%TYPE,

    IN_UNIT_PRICE PRODUCT.UNIT_PRICE%Type,

    PRODUCT_AVAILABLE PRODUCT.PRODUCT_AVAILABLE%TYPE

    );

procedure DROP_record (IN_product_ID PRODUCT.PRODUCT_ID%type );

 

END MANAGE_INVENTORY;

 

/

create or replace PACKAGE BODY MANAGE_INVENTORY  AS

 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

 

   procedure add_new_PRODUCT_CATEGORY(

    IN_PRODUCT_CATEGORY_DESC PRODUCT_CATEGORY.PRODUCT_CATEGORY_DESC%TYPE

    )

as

invalid_IN_PRODUCT_CATEGORY_DESC exception;

BEGIN

  if length(IN_PRODUCT_CATEGORY_DESC) <=0

      then

          raise invalid_IN_PRODUCT_CATEGORY_DESC ;     

    end if;

 

insert into PRODUCT_CATEGORY(

PRODUCT_CATEGORY_ID,

PRODUCT_CATEGORY_DESC

)

values(

prd_cat_seq.nextval,

IN_PRODUCT_CATEGORY_DESC

);

commit;

exception

when invalid_IN_PRODUCT_CATEGORY_DESC

then

    dbms_output.put_line('Please enter correct PRODUCT_CATEGORY_DESC');

when others

then dbms_output.put_line('Please enter correct values for PRODUCT_CATEGORY');

END add_new_PRODUCT_CATEGORY;

 

    procedure add_new_product(

    IN_PRODUCT_NAME PRODUCT.PRODUCT_NAME%TYPE,

    IN_PRODUCT_CATEGORY_ID PRODUCT.PRODUCT_CATEGORY_ID%TYPE,

    IN_qty_per_unit PRODUCT.qty_per_unit%TYPE,

    IN_UNIT_PRICE PRODUCT.UNIT_PRICE%Type,

    PRODUCT_AVAILABLE PRODUCT.PRODUCT_AVAILABLE%TYPE

    )

as

 

invalid_product_name exception;

invalid_product_category_ID exception;

invalid_qty_per_unit exception;

invalid_UNIT_PRICE exception;

invalid_PRODUCT_AVAILABLE exception;

 

BEGIN

 

  if length(IN_PRODUCT_NAME) <=0

      then

         raise invalid_product_name;

  elsif  IN_PRODUCT_CATEGORY_ID <= 0

      then

          raise invalid_product_category_ID;

  elsif  IN_qty_per_unit <=0

      then

          raise invalid_qty_per_unit;

  elsif  IN_UNIT_PRICE <=0

      then

          raise invalid_UNIT_PRICE;

  elsif  length(PRODUCT_AVAILABLE) <=0

      then

          raise invalid_PRODUCT_AVAILABLE ;     

    end if;

  

Insert into PRODUCT (

PRODUCT_ID,

PRODUCT_NAME,

PRODUCT_CATEGORY_ID,

QTY_PER_UNIT,

UNIT_PRICE,

PRODUCT_AVAILABLE

)

values(

    prd_seq.nextval,

    IN_PRODUCT_NAME ,

    IN_PRODUCT_CATEGORY_ID ,

    IN_qty_per_unit ,

    IN_UNIT_PRICE ,

    PRODUCT_AVAILABLE

);

commit;

 

exception

when invalid_product_name

then

    dbms_output.put_line('Please enter correct product name');

when invalid_product_category_ID

then

    dbms_output.put_line('Please enter correct product category ID');

when invalid_qty_per_unit

then

    dbms_output.put_line('Please enter correct quantity for product, It can not be zero or null');

when invalid_PRODUCT_AVAILABLE

then

    dbms_output.put_line('Please enter correct y or n for product availability');

when others

then dbms_output.put_line(sqlerrm);

END add_new_product;

 

procedure DROP_record (IN_product_ID PRODUCT.PRODUCT_ID%type)

as

pid number ;

IS_TRUE  number;

invalid_IN_PRODUCT_ID exception;

Object_not_found exception;

CURSOR c_productid is

      select product_id FROM  product; --where  lower(object_name) = 'abcd'    ;

 

begin

if IN_product_ID <=0

      then

          raise invalid_IN_PRODUCT_ID;     

    end if;

           

   IS_TRUE:= 0;    

OPEN c_productid;

   LOOP

   FETCH c_productid into pid;

      EXIT WHEN c_productid%notfound;  

if (pid =  IN_product_ID)

then

dbms_output.put_line ('it has come inside loop');

execute immediate 'delete from PRODUCT where product_ID = '|| IN_product_ID;

dbms_output.put_line(IN_product_ID || ' is deleted' );

IS_TRUE := 1;

end if;

end loop;

close c_productid;

 

if IS_TRUE = 0 then raise Object_not_found ;

   end if;

exception

when invalid_IN_PRODUCT_ID

then dbms_output.put_line ('Please enter valid Product_ID');

when Object_not_found

then dbms_output.put_line (IN_product_ID || ' pid not found');

when others

then dbms_output.put_line(sqlerrm);

 

end DROP_record;

 

END MANAGE_INVENTORY;

/
