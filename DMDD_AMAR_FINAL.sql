--EXECUTE FROM DATABASE ADMIN
--**********************************************************************************
set SERVEROUTPUT on;
declare
    is_true number;
begin
    select count(*)
    INTO IS_TRUE
    from all_users where username='APP_ADMIN_MITAL';
    IF IS_TRUE > 0
    THEN
    EXECUTE IMMEDIATE 'DROP USER APP_ADMIN_MITAL CASCADE';
    END IF;
END;
/
create user APP_ADMIN_MITAL identified by November2022 DEFAULT TABLESPACE data_ts QUOTA UNLIMITED ON data_ts ; 
GRANT CONNECT, RESOURCE TO APP_ADMIN_MITAL with admin option; 
--GRANT CONNECT TO APP_ADMIN_MITAL;  
grant create view, create procedure, create sequence, CREATE USER, DROP USER to APP_ADMIN_MITAL with admin option;  
--**********************************************************************************



--Execute from APP_ADMIN_MITAL
set SERVEROUTPUT on;
create or replace PACKAGE MANAGE_OBJECTS AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  
  procedure drop_objects(
    In_obj_Name VARCHAR,
    In_obj_type IN VARCHAR
    );

END MANAGE_OBJECTS;
/
create or replace PACKAGE BODY MANAGE_OBJECTS AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  
  procedure drop_objects(
    In_obj_name IN VARCHAR,
    In_obj_type IN VARCHAR
    )
as

IS_TRUE  number;
sql_stmt    VARCHAR2(200);
Invalid_In_obj_name exception;
Invalid_In_obj_type exception;
Object_not_found exception;
c_object_name user_objects.object_name%type;
c_object_type user_objects.object_type%type;
CURSOR c_objects is
      SELECT object_name, object_type FROM  user_objects; --where  lower(object_name) = 'abcd'    ;

BEGIN

if length(In_obj_name) <=0
      then
          raise Invalid_In_obj_name ;  
elsif length(In_obj_type) <= 0
        then
           raise Invalid_In_obj_type;
    end if;
   
    IS_TRUE := 0;

   OPEN c_objects;
   LOOP
   FETCH c_objects into c_object_name, c_object_type ;
      EXIT WHEN c_objects%notfound;
    IF (
    trim(lower(c_object_name)) = trim(lower(In_obj_name))
    and trim(lower(c_object_type)) = trim(lower(In_obj_type))
    )
    then
    sql_stmt := 'DROP '|| c_object_type || ' ' ||In_obj_name || ';';
    dbms_output.put_line(sql_stmt );
    --EXECUTE IMMEDIATE sql_stmt;
    execute immediate 'drop ' || c_object_type || ' ' || In_obj_name ; -- || ' cascade constraints';
    dbms_output.put_line(c_object_type|| ' ' || In_obj_name || ' is dropped.' );
    IS_TRUE := 1;
    END IF;
    --dbms_output.put_line(c_object_type||In_obj_name);
   
   END LOOP;
   
   CLOSE c_objects; 
   
   if IS_TRUE = 0 then raise Object_not_found ;
   end if;
      
commit;

EXCEPTION
when Invalid_In_obj_name
then dbms_output.put_line('Please enter correct value for object name');
when Invalid_In_obj_type
then dbms_output.put_line('Please enter correct value for object type');
when Object_not_found
then dbms_output.put_line( In_obj_type || ' ' || In_obj_name || ' not found');
when others
then dbms_output.put_line(sqlerrm);
--then dbms_output.put_line('Please pass correct parameters');

END drop_objects;

END MANAGE_OBJECTS;
/
create or replace PACKAGE MANAGE_USERS AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  procedure drop_users(
    In_user_Name VARCHAR
    );


END MANAGE_USERS;
/
create or replace PACKAGE BODY MANAGE_USERS AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  procedure drop_users(
    In_user_Name VARCHAR
    )
  as 
  IS_TRUE  number;
sql_stmt    VARCHAR2(200);
Invalid_In_user_name exception;
user_not_found exception ;
v_user_name all_users.username%type;
cursor c_all_users is
    select username from all_users;
BEGIN
if length(In_user_Name) <= 0
        then 
            raise Invalid_In_user_name;
    end if;

    IS_TRUE := 0;

    OPEN c_all_users; 
   LOOP 
   FETCH c_all_users into v_user_name; 
      EXIT WHEN c_all_users%notfound; 
      --dbms_output.put_line('My name is mital');
    IF (
    trim(lower(v_user_name)) = trim(lower(In_user_Name)) 
      )
    then 
    sql_stmt := 'DROP user '||In_user_Name;
    dbms_output.put_line(sql_stmt );
    EXECUTE IMMEDIATE sql_stmt;
    --execute immediate 'drop user '||upper(trim(in_user_name))  ;
    dbms_output.put_line(In_user_Name||  ' user is dropped.' );
    IS_TRUE := 1;
    END IF;
    --dbms_output.put_line(c_object_type||In_obj_name);

   END LOOP; 

   CLOSE c_all_users; 

   if IS_TRUE = 0 then raise user_not_found ;
   end if;

commit;

EXCEPTION
when Invalid_In_user_name
then dbms_output.put_line('Please enter correct username');
when user_not_found
then dbms_output.put_line( In_user_Name || ' not found');
when others
then dbms_output.put_line(sqlerrm);
END drop_users;

END MANAGE_USERS;
/
exec manage_objects.drop_objects('INSURANCE','table');
exec manage_objects.drop_objects('INSURANCE','view');
exec manage_objects.drop_objects('INSURANCE_PRICE','table');
exec manage_objects.drop_objects('INSURANCE_PRICE','view');
exec manage_objects.drop_objects('courier','table');
exec manage_objects.drop_objects('courier','view');
exec manage_objects.drop_objects('claim','table');
exec manage_objects.drop_objects('claim','view');
exec manage_objects.drop_objects('claim_category','table');
exec manage_objects.drop_objects('claim_category','view');
exec manage_objects.drop_objects('warranty','table');
exec manage_objects.drop_objects('warranty','view');
exec manage_objects.drop_objects('ORDERS','table');
exec manage_objects.drop_objects('ORDERS','view');
exec manage_objects.drop_objects('OFFERS','table');
exec manage_objects.drop_objects('OFFERS','view');
exec manage_objects.drop_objects('CUSTOMER','table');
exec manage_objects.drop_objects('CUSTOMER','view');
exec manage_objects.drop_objects('CUSTOMER_CATEGORY','table');
exec manage_objects.drop_objects('CUSTOMER_CATEGORY','view');
exec manage_objects.drop_objects('PRODUCT','table');
exec manage_objects.drop_objects('PRODUCT','view');
exec manage_objects.drop_objects('PRODUCT_CATEGORY','table');
exec manage_objects.drop_objects('PRODUCT_CATEGORY','view');
exec manage_objects.drop_objects('ORDERS_CHANGES_TRACK','table');

exec manage_objects.drop_objects('ORDER_seq','sequence');
exec manage_objects.drop_objects('INSURANCE_seq','sequence');
exec manage_objects.drop_objects('INSURANCE_PRICE_seq','sequence');
exec manage_objects.drop_objects('cust_seq','sequence');
exec manage_objects.drop_objects('cust_cat_seq','sequence');
exec manage_objects.drop_objects('prd_seq','sequence');
exec manage_objects.drop_objects('prd_cat_seq','sequence');
exec manage_objects.drop_objects('WAR_SEQ','sequence');
exec manage_objects.drop_objects('COURIER_SEQ','sequence');
exec manage_objects.drop_objects('CLAIM_SEQ','sequence');
exec manage_objects.drop_objects('CLAIM_CAT_SEQ','sequence');

Exec manage_objects.drop_objects('INVENTORY_STATUS','view');
Exec manage_objects.drop_objects('get_total_order_price','function');


--exec MANAGE_USERS.drop_users('App_admin_mital');
exec MANAGE_USERS.drop_users('ALEX');
exec MANAGE_USERS.drop_users('YASH');
exec MANAGE_USERS.drop_users('JACK');
exec MANAGE_USERS.drop_users('MEENA');
exec MANAGE_USERS.drop_users('CLAIM_MANAGER_ADMIN');
exec MANAGE_USERS.drop_users('COURIER_MANAGER_ADMIN');
exec MANAGE_USERS.drop_users('SALES_MANAGER_ADMIN');
exec MANAGE_USERS.drop_users('INVENTORY_MANAGER_ADMIN');

CREATE SEQUENCE CLAIM_CAT_SEQ
START WITH 9001
INCREMENT BY 1
NOCACHE   
NOCYCLE   ;


CREATE SEQUENCE CLAIM_SEQ
INCREMENT BY 1
START WITH 8001
NOCACHE   
NOCYCLE ;

CREATE SEQUENCE COURIER_SEQ
INCREMENT BY 1
START WITH 3001
NOCACHE   
NOCYCLE;


CREATE SEQUENCE  WAR_SEQ
INCREMENT BY 1
START WITH 1101
NOCACHE   
NOCYCLE   ;

--CREATE SEQUENCE  BILL_NO_SEQ
-- START WITH 7001
-- INCREMENT BY 1
-- NOCACHE
-- NOCYCLE;


CREATE SEQUENCE prd_cat_seq
START WITH     4001
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE prd_seq
START WITH     5001
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE cust_cat_seq
START WITH     2001
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE cust_seq
START WITH     1001
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE INSURANCE_PRICE_seq
START WITH     7001
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE INSURANCE_seq
START WITH     2101
INCREMENT BY   1
NOCACHE
NOCYCLE;

CREATE SEQUENCE ORDER_seq
START WITH     6001
INCREMENT BY   1
NOCACHE
NOCYCLE;


CREATE TABLE PRODUCT_CATEGORY(
PRODUCT_CATEGORY_ID NUMBER PRIMARY KEY,
PRODUCT_CATEGORY_DESC VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_PRODUCT_CATEGORY AS SELECT * FROM PRODUCT_CATEGORY;

CREATE TABLE PRODUCT(
PRODUCT_ID NUMBER PRIMARY KEY,
PRODUCT_NAME VARCHAR(100) NOT NULL,
PRODUCT_CATEGORY_ID REFERENCES PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID) ON DELETE CASCADE,
QTY_PER_UNIT NUMBER CHECK(QTY_PER_UNIT >= 0),
UNIT_PRICE NUMBER NOT NULL,
PRODUCT_AVAILABLE CHAR(1) NOT NULL
);
CREATE OR REPLACE VIEW  V_PRODUCT AS SELECT * FROM PRODUCT;

CREATE TABLE CUSTOMER_CATEGORY(
CUSTOMER_CATEGORY_ID NUMBER PRIMARY KEY,
CUSTOMER_CATEGORY_DESC VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_CUSTOMER_CATEGORY AS SELECT * FROM CUSTOMER_CATEGORY;


CREATE TABLE CUSTOMER(
CUSTOMER_ID NUMBER PRIMARY KEY,
CUSTOMER_CATEGORY_ID NUMBER REFERENCES CUSTOMER_CATEGORY(CUSTOMER_CATEGORY_ID) ON DELETE CASCADE,
CUSTOMER_FNAME VARCHAR(100) NOT NULL,
CUSTOMER_LNAME VARCHAR(100) NOT NULL,
CUSTOMER_ADDRESS VARCHAR(100) NOT NULL,
CUSTOMER_PHONE NUMBER NOT NULL,
CUSTOMER_EMAIL VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_CUSTOMER AS SELECT * FROM CUSTOMER;

CREATE TABLE OFFERS(
OFFER_ID NUMBER PRIMARY KEY,
OFFER_DESC VARCHAR(100) NOT NULL,
CUSTOMER_CATEGORY_ID REFERENCES CUSTOMER_CATEGORY(CUSTOMER_CATEGORY_ID) ON DELETE CASCADE
);
CREATE OR REPLACE VIEW  V_OFFERS AS SELECT * FROM OFFERS;


CREATE TABLE ORDERS(
ORDERS_ID NUMBER PRIMARY KEY,
CUSTOMER_ID NUMBER REFERENCES CUSTOMER(CUSTOMER_ID) ON DELETE CASCADE,
PRODUCT_ID  NUMBER REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE,
--BILL_NO NUMBER ,--REFERENCES PAYMENTS(BILL_NO) ON DELETE CASCADE,
WARRANTY_ID NUMBER,-- REFERENCES WARRANTY(WARRANTY_ID) ON DELETE CASCADE,
OFFER_ID NUMBER REFERENCES OFFERS(OFFER_ID) ON DELETE CASCADE,
--INSURANCE_ID NUMBER REFERENCES INSURANCE(INSURANCE_ID) ON DELETE CASCADE,
ORDER_DATE DATE DEFAULT SYSDATE,
DISPATCH_DATE DATE DEFAULT SYSDATE,
ORDER_PRICE NUMBER NOT NULL,
--DELETED_ORDER char(1) NOT NULL,
PAY_STATUS VARCHAR(100) NOT NULL,
ORDER_QTY NUMBER NOT NULL,
--DELETE_QTY NUMBER NOT NULL,
INSURANCE_STATUS VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_ORDERS AS SELECT * FROM ORDERS;

CREATE TABLE ORDERS_CHANGES_TRACK
   (           ORDERS_ID NUMBER,
               CUSTOMER_ID NUMBER,
               PRODUCT_ID NUMBER,
               WARRANTY_ID NUMBER,
               OFFER_ID NUMBER,
               ORDER_DATE DATE DEFAULT SYSDATE,
               DISPATCH_DATE DATE DEFAULT SYSDATE,
               ORDER_PRICE NUMBER,
               PAY_STATUS VARCHAR2(100),
               ORDER_QTY NUMBER,
               INSURANCE_STATUS VARCHAR(100 ),
               EVENT_TYPE VARCHAR(100)
   )  ;


/
create or replace trigger track_order_changes
before delete or insert or update
on ORDERS
referencing old as o new as n
for each row
begin
  if deleting  then
     insert into ORDERS_Changes_Track
        (
        ORDERS_ID ,
        CUSTOMER_ID ,
        PRODUCT_ID ,
        WARRANTY_ID ,
        OFFER_ID ,
        ORDER_DATE ,
        DISPATCH_DATE ,
        ORDER_PRICE ,
        PAY_STATUS,
        ORDER_QTY ,
        INSURANCE_STATUS ,
        EVENT_TYPE
        )
        values(
        :o.ORDERS_ID ,
        :o.CUSTOMER_ID ,
        :o.PRODUCT_ID ,
        :o.WARRANTY_ID ,
        :o.OFFER_ID ,
        :o.ORDER_DATE ,
        :o.DISPATCH_DATE ,
        :o.ORDER_PRICE ,
        :o.PAY_STATUS,
        :o.ORDER_QTY ,
        :o.INSURANCE_STATUS ,
        'deleting'
        );
        end if;
  if inserting  then
     insert into ORDERS_Changes_Track
        (
        ORDERS_ID ,
        CUSTOMER_ID ,
        PRODUCT_ID ,
        WARRANTY_ID ,
        OFFER_ID ,
        ORDER_DATE ,
        DISPATCH_DATE ,
        ORDER_PRICE ,
        PAY_STATUS,
        ORDER_QTY ,
        INSURANCE_STATUS ,
        EVENT_TYPE
        )
        values(
        :n.ORDERS_ID ,
        :n.CUSTOMER_ID ,
        :n.PRODUCT_ID ,
        :n.WARRANTY_ID ,
       :n.OFFER_ID ,
        :n.ORDER_DATE ,
        :n.DISPATCH_DATE ,
        :n.ORDER_PRICE ,
        :n.PAY_STATUS,
        :n.ORDER_QTY ,
        :n.INSURANCE_STATUS ,
        'inserting'
        );
        end if;
  if updating  then
     insert into ORDERS_Changes_Track
        (
        ORDERS_ID ,
        CUSTOMER_ID ,
        PRODUCT_ID ,
        WARRANTY_ID ,
        OFFER_ID ,
        ORDER_DATE ,
        DISPATCH_DATE ,
        ORDER_PRICE ,
        PAY_STATUS,
        ORDER_QTY ,
        INSURANCE_STATUS ,
        EVENT_TYPE
        )
        values(
        :n.ORDERS_ID ,
        :n.CUSTOMER_ID ,
        :n.PRODUCT_ID ,
        :n.WARRANTY_ID ,
        :n.OFFER_ID ,
        :n.ORDER_DATE ,
       :n.DISPATCH_DATE ,
        :n.ORDER_PRICE ,
        :n.PAY_STATUS,
        :n.ORDER_QTY ,
        :n.INSURANCE_STATUS ,
        'updating'
        );
        end if;

end;
/


CREATE TABLE WARRANTY(
WARRANTY_ID NUMBER PRIMARY KEY,
PRODUCT_ID NUMBER REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE,
ORDERS_ID NUMBER REFERENCES ORDERS(ORDERS_ID) ON DELETE CASCADE,
START_DATE DATE DEFAULT SYSDATE,
End_DATE DATE DEFAULT SYSDATE
);
CREATE OR REPLACE VIEW  V_WARRANTY AS SELECT * FROM WARRANTY;

CREATE TABLE CLAIM_CATEGORY(
CLAIM_CATEGORY_ID NUMBER PRIMARY KEY,
CLAIM_DESCRIPTION VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_CLAIM_CATEGORY AS SELECT * FROM CLAIM_CATEGORY;

CREATE TABLE CLAIM(
CLAIM_ID NUMBER PRIMARY KEY,
CLAIM_CATEGORY_ID NUMBER REFERENCES CLAIM_CATEGORY(CLAIM_CATEGORY_ID) ON DELETE CASCADE,
ORDERS_ID NUMBER REFERENCES orders(ORDERS_ID) ON DELETE CASCADE,
WARRANTY_ID VARCHAR(100) NOT NULL,
ISSUE_DATE DATE DEFAULT SYSDATE,
RESOLVE_DATE DATE,
INSURANCE_ID NUMBER
);
CREATE OR REPLACE VIEW  V_CLAIM AS SELECT * FROM CLAIM;

--ALTER TABLE CLAIM MODIFY INSURANCE_ID NUMBER NULL
CREATE TABLE COURIER(
COURIER_ID NUMBER PRIMARY KEY,
ORDERS_ID NUMBER REFERENCES orders(ORDERS_ID) ON DELETE CASCADE,
COURIER_NAME VARCHAR(100) NOT NULL,
DELIVERY_STATUS VARCHAR(100) NOT NULL,
PAY_STATUS VARCHAR(100) NOT NULL
);
CREATE OR REPLACE VIEW  V_COURIER AS SELECT * FROM COURIER;

CREATE TABLE INSURANCE_PRICE(
INSURANCE_PRICE_ID NUMBER PRIMARY KEY,
PRODUCT_ID REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE,
PRODUCT_CATEGORY_ID REFERENCES PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID) ON DELETE CASCADE,
INSURANCE_PRICE NUMBER NOT NULL
);
CREATE OR REPLACE VIEW  V_INSURANCE_PRICE AS SELECT * FROM INSURANCE_PRICE;

CREATE TABLE INSURANCE(
INSURANCE_ID NUMBER PRIMARY KEY,
INSURANCE_START_DATE DATE DEFAULT SYSDATE,
INSURANCE_END_DATE DATE DEFAULT ADD_MONTHS(SYSDATE,12),
ORDERS_ID REFERENCES ORDERS(ORDERS_ID) ON DELETE CASCADE,
INSURANCE_PRICE_ID REFERENCES INSURANCE_PRICE(INSURANCE_PRICE_ID) ON DELETE CASCADE
);
CREATE OR REPLACE VIEW  V_INSURANCE AS SELECT * FROM INSURANCE;



create view INVENTORY_STATUS as
select PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY_DESC, QTY_PER_UNIT as Available_Quantity,
CASE
when QTY_PER_UNIT < 51 then 'Restock Product'
when QTY_PER_UNIT > 50 then 'Available Product'
end  as Product_Availability_Status
from PRODUCT inner join PRODUCT_CATEGORY
on PRODUCT.PRODUCT_CATEGORY_ID = PRODUCT_CATEGORY.PRODUCT_CATEGORY_ID;
/
create or replace FUNCTION get_total_order_price(
IN_ord_qty NUMBER,
IN_INSURANCE_STATUS ORDERS.INSURANCE_STATUS%type,
IN_PRODUCT_NAME PRODUCT.product_name%TYPE,
IN_CUST_CATEGORY CUSTOMER_CATEGORY.CUSTOMER_CATEGORY_ID%TYPE

)
RETURN NUMBER
AS
total_order_price NUMBER := 0;
v_insurance_price NUMBER;
v_offer_id NUMBER;
BEGIN

select O.offer_ID into v_offer_id
from offers O
inner join customer_category CC
on O.customer_category_ID = CC.customer_category_id
where CC.customer_category_id = IN_CUST_CATEGORY;
DBMS_OUTPUT.PUT_LINE(v_offer_id);
if (IN_INSURANCE_STATUS = 'N')
then
    select ((p.Unit_PRICE  * (1-(v_offer_id/100)))* IN_ord_qty)
    into total_order_price
    from PRODUCT p
    where lower(trim(p.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));
    RETURN total_order_price;
else
    select (((p.Unit_PRICE  * (1-(v_offer_id/100))) + i.insurance_price)* IN_ord_qty)
    into total_order_price
    from PRODUCT p join insurance_price i
    on p.product_id = i.product_id
    where lower(trim(p.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));
    RETURN total_order_price;
end if;


RETURN total_order_price;
END;

/
create or replace PACKAGE MANAGE_CLAIM AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_CLAIM_CATEGORY(
    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE
    );
   
    procedure add_new_CLAIM(
    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE,
    IN_ORDERS_ID CLAIM.ORDERS_ID%TYPE,
    IN_WARRANTY_ID CLAIM.WARRANTY_ID%TYPE,
    IN_INSURANCE_ID CLAIM.INSURANCE_ID%TYPE
    );

procedure resolve_CLAIM(
IN_claim_ID claim.claim_ID%type
);

procedure DROP_record_claim (IN_claim_ID CLAIM.CLAIM_ID%type );

procedure DROP_record_claim_category (IN_claim_category_ID claim_category.claim_category_ID%type );

END MANAGE_CLAIM;
/
create or replace PACKAGE BODY MANAGE_CLAIM AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_CLAIM_CATEGORY(
    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE
    )
as
invalid_IN_CLAIM_DESCRIPTION exception;
BEGIN
  if length(IN_CLAIM_DESCRIPTION) <=0
      then
          raise invalid_IN_CLAIM_DESCRIPTION ;     
    end if;

insert into CLAIM_CATEGORY(
CLAIM_CATEGORY_ID,
CLAIM_DESCRIPTION
)
VALUES(
claim_cat_seq.nextval,
IN_CLAIM_DESCRIPTION
);
commit;
exception
when invalid_IN_CLAIM_DESCRIPTION
then
    dbms_output.put_line('Please enter correct CALIM_CATEGORY_DESC');
when others
then dbms_output.put_line('Please enter correct values for CLAIM_CATEGORY');

END add_new_CLAIM_CATEGORY;

   
    procedure add_new_CLAIM (
    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE,
    IN_ORDERS_ID CLAIM.ORDERS_ID%TYPE,
    IN_WARRANTY_ID CLAIM.WARRANTY_ID%TYPE,
    IN_INSURANCE_ID CLAIM.INSURANCE_ID%TYPE
    )
AS
    invalid_CLAIM_DESCRIPTION exception;
    invalid_ORDERS_ID exception;
    invalid_WARRANTY_ID exception;
    invalid_INSURANCE_ID exception;
    claimAlreadyExists exception;
    v_orders_ID number;
    v_warranty_ID number;
    v_insurance_ID number;
    v_claim_category_id number;
    v_cl_claim_ID number;
    v_cl_orders_ID number;
    IS_ORD_TRUE number :=0;
    IS_WAR_TRUE number :=0;
    IS_INS_TRUE number :=0;
    IS_claimcat_TRUE number :=0;
    IS_INS_PURCCHASED number;
    v_ins_status varchar(3);
    CURSOR c_orderdetail is
      select  o.orders_ID,o.warranty_ID,i.insurance_ID,o.insurance_status
      from  insurance i right join orders o on i.orders_id = o.orders_id where ORDER_QTY <> 0;
    cursor c_claim is
        select claim_category_id from claim_category where lower(trim(claim_description)) = lower(trim(IN_CLAIM_DESCRIPTION)) ;
    cursor c_claimAlreadyExists is
        select claim_ID, orders_ID from claim;
   
BEGIN


OPEN c_orderdetail;
   LOOP
   FETCH c_orderdetail into v_orders_ID, v_warranty_ID,v_insurance_ID,v_ins_status;
      EXIT WHEN c_orderdetail%notfound;
if (v_warranty_ID =  IN_WARRANTY_ID)
then
dbms_output.put_line ('it has come inside orderdetail war loop');
IS_WAR_TRUE := 1;
end if;
if ( v_orders_ID = IN_orders_id)
then
dbms_output.put_line ('it has come inside orderdetail ord loop');
IS_ORD_TRUE := 1;
end if;
if ( (v_INSURANCE_ID = IN_INSURANCE_id) or (trim(upper(v_ins_status)) = 'N' and v_orders_ID = IN_orders_id) )
then
dbms_output.put_line ('it has come inside orderdetail ins loop');
IS_INS_TRUE := 1;
exit;
end if;
end loop;
close c_orderdetail;

OPEN c_claim;
   LOOP
   FETCH c_claim into v_claim_category_id;
      EXIT WHEN c_claim%notfound;
if (v_claim_category_id <> 0)
then
dbms_output.put_line ('it has come inside claim loop');
IS_claimcat_TRUE := 1;
end if;
end loop;
close c_claim;

OPEN c_claimAlreadyExists;
   LOOP
   FETCH c_claimAlreadyExists into v_cl_claim_ID, v_cl_orders_ID;
      EXIT WHEN c_claimAlreadyExists%notfound;
if (v_cl_orders_ID = IN_ORDERS_ID)
then
dbms_output.put_line ('it has come inside claimAlreadyExists loop');
raise claimAlreadyExists;
end if;
end loop;
close c_claimAlreadyExists;

  if (length(IN_CLAIM_DESCRIPTION) <=0 or IS_claimcat_TRUE = 0)
      then
          raise invalid_CLAIM_DESCRIPTION ;     
    
  elsif (IN_ORDERS_ID <=0 or IS_ORD_TRUE = 0)
      then
          raise invalid_ORDERS_ID ;     
    
    
  elsif (IN_WARRANTY_ID <=0 or IS_WAR_TRUE = 0)
      then
          raise invalid_WARRANTY_ID ;     
    
  elsif (IN_INSURANCE_ID<=0 or IS_INS_TRUE = 0)
      then
          raise invalid_INSURANCE_ID ;     
    end if;

insert into claim(
claim_id,
CLAIM_CATEGORY_ID,
ORDERS_ID,
WARRANTY_ID,
ISSUE_DATE,
RESOLVE_DATE,
INSURANCE_ID
)
values(
CLAIM_SEQ.NEXTVAL,
v_claim_category_id,
v_orders_ID,
v_warranty_ID,
sysdate ,
'31-DEC-9999',
v_insurance_ID
);
   
commit;

exception
when invalid_CLAIM_DESCRIPTION
then
    dbms_output.put_line('Please enter correct claim Description');
when invalid_ORDERS_ID
then
    dbms_output.put_line('Please enter correct order_id');
when invalid_WARRANTY_ID
then
    dbms_output.put_line('Please enter correct warranty id');
when invalid_INSURANCE_ID
then
    dbms_output.put_line('Please enter correct insurance id');
when claimAlreadyExists
then dbms_output.put_line('claim#' || v_cl_claim_ID || 'already exists for order#'||v_cl_orders_ID);
when others
then dbms_output.put_line(sqlerrm);

END add_new_claim;


procedure resolve_CLAIM(
IN_claim_ID claim.claim_ID%type
)
as
cursor c_claim is
        select claim_ID, orders_ID, warranty_ID,insurance_id ,issue_date, resolve_date from claim;
v_claim_ID number;
v_orders_ID number;
v_Warranty_ID number;
v_insurance_ID number;
v_issue_date date;
v_resolve_date date;
IS_CLAIM_TRUE number := 0;
invalid_Claim_ID exception;
resolved_claim exception;

BEGIN
OPEN c_claim;
   LOOP
   FETCH c_claim into v_claim_ID, v_orders_ID,v_Warranty_ID,v_insurance_ID,v_issue_date,v_resolve_date;
      EXIT WHEN c_claim%notfound;
if (v_claim_ID = in_claim_ID)
then
dbms_output.put_line ('it has come inside claim loop');
IS_CLAIM_TRUE := 1;
EXIT;
end if;
end loop;
close c_claim;

if IS_CLAIM_TRUE = 0
then raise invalid_Claim_ID;
end if;

if  (IS_CLAIM_TRUE =1 and v_resolve_date <> '31-DEC-9999')
then raise resolved_claim;
elsif  (IS_CLAIM_TRUE =1 and v_insurance_ID is not null)
then update claim
set resolve_date = sysdate
where claim.issue_date < (select insurance_end_date
from insurance where insurance_ID = v_insurance_ID )
and claim_ID = IN_claim_ID;
commit;
elsif (v_insurance_ID is null)
then dbms_output.put_line('This is to let you know that claim is not covered under insurance, please make the payment');
end if;

EXCEPTION
when invalid_Claim_ID
then dbms_output.put_line('entered claim# '|| in_claim_ID || ' does not exist');
when resolved_claim
then dbms_output.put_line('entered claim# '|| in_claim_ID || ' is already resolved');
when others
then dbms_output.put_line(sqlerrm);
END resolve_CLAIM;

procedure DROP_record_claim (IN_claim_ID claim.claim_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_claim_ID exception;
Object_not_found exception;
CURSOR c_claimid is
      select claim_id FROM  claim; --where  lower(object_name) = 'abcd'    ;

begin
if IN_claim_ID <=0
      then
          raise invalid_IN_claim_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_claimid;
   LOOP
   FETCH c_claimid into cid;
      EXIT WHEN c_claimid%notfound;   
if (cid =  IN_claim_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from claim where claim_ID = '|| IN_claim_ID;
commit;
dbms_output.put_line(IN_claim_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_claimid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_claim_ID
then dbms_output.put_line ('Please enter valid claim_ID');
when Object_not_found
then dbms_output.put_line (IN_claim_ID || ' cid not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record_claim;


procedure DROP_record_claim_category (IN_claim_category_ID claim_category.claim_category_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_claim_category_ID exception;
Object_not_found exception;
CURSOR c_claim_categoryid is
      select claim_category_id FROM  claim_category; --where  lower(object_name) = 'abcd'    ;

begin
if IN_claim_category_ID <=0
      then
          raise invalid_IN_claim_category_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_claim_categoryid;
   LOOP
   FETCH c_claim_categoryid into cid;
      EXIT WHEN c_claim_categoryid%notfound;   
if (cid =  IN_claim_category_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from claim_category where claim_category_ID = '|| IN_claim_category_ID;
commit;
dbms_output.put_line(IN_claim_category_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_claim_categoryid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_claim_category_ID
then dbms_output.put_line ('Please enter valid claim_category_ID');
when Object_not_found
then dbms_output.put_line (IN_claim_category_ID || ' cid not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record_claim_category;


END MANAGE_CLAIM;
/

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
commit;
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
commit;
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

create or replace PACKAGE MANAGE_CUSTOMERS AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
procedure add_new_CUSTOMER_CATEGORY(
    IN_CUSTOMER_CATEGORY_DESC IN CUSTOMER_CATEGORY.CUSTOMER_CATEGORY_DESC%TYPE
    );

procedure add_new_CUSTOMER(
IN_CUSTOMER_CATEGORY_ID IN CUSTOMER.CUSTOMER_CATEGORY_ID%type,
IN_CUSTOMER_FNAME IN CUSTOMER.CUSTOMER_FNAME%type,
IN_CUSTOMER_LNAME IN CUSTOMER.CUSTOMER_LNAME%type,
IN_CUSTOMER_ADDRESS IN CUSTOMER.CUSTOMER_ADDRESS%type,
IN_CUSTOMER_PHONE IN CUSTOMER.CUSTOMER_PHONE%type,
IN_CUSTOMER_EMAIL IN CUSTOMER.CUSTOMER_EMAIL%type
);

procedure DROP_record (IN_customer_ID customer.customer_ID%type );


END MANAGE_CUSTOMERS;
/

create or replace PACKAGE BODY MANAGE_CUSTOMERS AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
procedure add_new_CUSTOMER_CATEGORY(
    IN_CUSTOMER_CATEGORY_DESC IN CUSTOMER_CATEGORY.CUSTOMER_CATEGORY_DESC%TYPE
    )
as

invalid_IN_CUSTOMER_CATEGORY_DESC exception;

BEGIN
  if length(IN_CUSTOMER_CATEGORY_DESC) <=0
      then
          raise invalid_IN_CUSTOMER_CATEGORY_DESC ;      
    end if;

insert into CUSTOMER_CATEGORY(
CUSTOMER_CATEGORY_ID,
CUSTOMER_CATEGORY_DESC
)
values(
cust_cat_seq.nextval,
IN_CUSTOMER_CATEGORY_DESC
);
commit;

exception
when invalid_IN_CUSTOMER_CATEGORY_DESC
then
    dbms_output.put_line('Please enter correct CUSTOMER_CATEGORY_DESC');
when others
then dbms_output.put_line('Please enter correct values for CUSTOMER_CATEGORY');

END add_new_CUSTOMER_CATEGORY;

procedure add_new_CUSTOMER(
IN_CUSTOMER_CATEGORY_ID IN CUSTOMER.CUSTOMER_CATEGORY_ID%type,
IN_CUSTOMER_FNAME IN CUSTOMER.CUSTOMER_FNAME%type,
IN_CUSTOMER_LNAME IN CUSTOMER.CUSTOMER_LNAME%type,
IN_CUSTOMER_ADDRESS IN CUSTOMER.CUSTOMER_ADDRESS%type,
IN_CUSTOMER_PHONE IN CUSTOMER.CUSTOMER_PHONE%type,
IN_CUSTOMER_EMAIL IN CUSTOMER.CUSTOMER_EMAIL%type
)
as

invalid_CUSTOMER_CATEGORY_ID exception;
invalid_CUSTOMER_FNAME exception;
invalid_CUSTOMER_LNAME exception;
invalid_CUSTOMER_ADDRESS exception;
invalid_CUSTOMER_PHONE exception;
invalid_CUSTOMER_EMAIL exception;

BEGIN

if length(IN_CUSTOMER_CATEGORY_ID) <=0
      then
         raise invalid_CUSTOMER_CATEGORY_ID;
  elsif length( IN_CUSTOMER_FNAME) <= 0
      then
          raise invalid_CUSTOMER_FNAME;
  elsif length( IN_CUSTOMER_LNAME) <=0
      then
          raise invalid_CUSTOMER_LNAME;
  elsif  length(IN_CUSTOMER_ADDRESS) <=0
      then
          raise invalid_CUSTOMER_ADDRESS;
  elsif  length(IN_CUSTOMER_PHONE) <=0
      then
          raise invalid_CUSTOMER_PHONE ; 
  elsif length(IN_CUSTOMER_EMAIL) <=0
        then
          raise invalid_CUSTOMER_EMAIL;
    end if;

insert into CUSTOMER(
CUSTOMER_ID,
CUSTOMER_CATEGORY_ID,
CUSTOMER_FNAME,
CUSTOMER_LNAME,
CUSTOMER_ADDRESS,
CUSTOMER_PHONE,
CUSTOMER_EMAIL
)values(
cust_seq.nextval,
IN_CUSTOMER_CATEGORY_ID ,
IN_CUSTOMER_FNAME ,
IN_CUSTOMER_LNAME ,
IN_CUSTOMER_ADDRESS ,
IN_CUSTOMER_PHONE ,
IN_CUSTOMER_EMAIL
);
commit;
EXCEPTION
when invalid_CUSTOMER_CATEGORY_ID
then dbms_output.put_line('Please enter correct customer category ID');
when invalid_CUSTOMER_FNAME
then dbms_output.put_line('Please enter correct value for customer first name');
when invalid_CUSTOMER_LNAME
then dbms_output.put_line('Please enter correct value for customer last name');
when invalid_CUSTOMER_ADDRESS
then dbms_output.put_line('Please enter correct value for customer address');
when invalid_CUSTOMER_PHONE
then dbms_output.put_line('Please enter correct value for customer phone number');
when invalid_CUSTOMER_EMAIL
then dbms_output.put_line('Please enter correct value for customer email');
when others
then dbms_output.put_line(sqlerrm);

END add_new_CUSTOMER;


procedure DROP_record (IN_customer_ID customer.customer_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_customer_ID exception;
Object_not_found exception;
CURSOR c_customerid is
      select customer_id FROM  customer; --where  lower(object_name) = 'abcd'    ;

begin
if IN_customer_ID <=0
      then
          raise invalid_IN_customer_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_customerid;
   LOOP
   FETCH c_customerid into cid;
      EXIT WHEN c_customerid%notfound;   
if (cid =  IN_customer_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from customer where customer_ID = '|| IN_customer_ID;
commit;
dbms_output.put_line(IN_customer_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_customerid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_customer_ID
then dbms_output.put_line ('Please enter valid customer_ID');
when Object_not_found
then dbms_output.put_line (IN_customer_ID || ' cid not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record;

END MANAGE_CUSTOMERS;
/
create or replace PACKAGE MANAGE_INSURANCE AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_INSURANCE_PRICE(
    IN_PRODUCT_ID INSURANCE_PRICE.PRODUCT_ID%TYPE,
    IN_PRODUCT_CATEGORY_ID INSURANCE_PRICE.PRODUCT_CATEGORY_ID%TYPE,
    IN_INSURANCE_PRICE INSURANCE_PRICE.INSURANCE_PRICE%TYPE
    );

  procedure add_new_INSURANCE(
    IN_INSURANCE_START_DATE INSURANCE.INSURANCE_START_DATE%TYPE,
    IN_INSURANCE_END_DATE INSURANCE.INSURANCE_END_DATE%TYPE,
    IN_ORDERS_ID INSURANCE.ORDERS_ID%TYPE,
    IN_INSURANCE_PRICE_ID INSURANCE.INSURANCE_PRICE_ID%TYPE
    );

  procedure DROP_record_Insurance (IN_Insurance_ID Insurance.Insurance_ID%type );


END MANAGE_INSURANCE;
/
create or replace PACKAGE BODY MANAGE_INSURANCE AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_INSURANCE_PRICE(
    IN_PRODUCT_ID INSURANCE_PRICE.PRODUCT_ID%TYPE,
    IN_PRODUCT_CATEGORY_ID INSURANCE_PRICE.PRODUCT_CATEGORY_ID%TYPE,
    IN_INSURANCE_PRICE INSURANCE_PRICE.INSURANCE_PRICE%TYPE
    )
AS
    invalid_PRODUCT_ID exception;
   invalid_PRODUCT_CATEGORY_ID exception;
    invalid_INSURANCE_PRICE exception;
BEGIN
if IN_PRODUCT_ID <=0
      then
         raise invalid_PRODUCT_ID;
  elsif  IN_PRODUCT_CATEGORY_ID <= 0
      then
          raise invalid_PRODUCT_CATEGORY_ID;
  elsif  IN_INSURANCE_PRICE <= 0
      then
          raise invalid_INSURANCE_PRICE;
    end if;

Insert into INSURANCE_PRICE (
    INSURANCE_PRICE_ID,
    PRODUCT_ID,
    PRODUCT_CATEGORY_ID,
    INSURANCE_PRICE
)
values(
    INSURANCE_PRICE_seq.nextval,
    IN_PRODUCT_ID,
    IN_PRODUCT_CATEGORY_ID,
    IN_INSURANCE_PRICE
);
commit;

exception
when invalid_PRODUCT_ID
then
    dbms_output.put_line('Please enter correct PRODUCT ID');
when invalid_PRODUCT_CATEGORY_ID
then
    dbms_output.put_line('Please enter correct PRODUCT CATEGORY ID');
when invalid_INSURANCE_PRICE
then
    dbms_output.put_line('Please enter correct INSURANCE PRICE');
when others
then dbms_output.put_line('Please enter correct values in INSURANCE PRICE Table');

END add_new_insurance_price;

procedure add_new_INSURANCE(
    IN_INSURANCE_START_DATE INSURANCE.INSURANCE_START_DATE%TYPE,
    IN_INSURANCE_END_DATE INSURANCE.INSURANCE_END_DATE%TYPE,
    IN_ORDERS_ID INSURANCE.ORDERS_ID%TYPE,
    IN_INSURANCE_PRICE_ID INSURANCE.INSURANCE_PRICE_ID%TYPE
    )
as
   invalid_INSURANCE_START_DATE exception;
    invalid_INSURANCE_END_DATE exception;
    invalid_ORDERS_ID exception;
    invalid_INSURANCE_PRICE_ID exception;

BEGIN
  if length(IN_INSURANCE_START_DATE) <=0
      then
          raise invalid_INSURANCE_START_DATE ;     
    
  elsif length(IN_INSURANCE_END_DATE) <=0
      then
          raise invalid_INSURANCE_END_DATE ; 
  elsif  IN_ORDERS_ID <=0
      then
          raise invalid_ORDERS_ID ;
  elsif  IN_INSURANCE_PRICE_ID <=0
      then
          raise invalid_INSURANCE_PRICE_ID ;
    end if;

INSERT INTO INSURANCE(
INSURANCE_ID,
INSURANCE_START_DATE,
INSURANCE_END_DATE,
ORDERS_ID,
INSURANCE_PRICE_ID
)
VALUES
(
INSURANCE_seq.nextval,
IN_INSURANCE_START_DATE,
IN_INSURANCE_END_DATE,
IN_ORDERS_ID,
IN_INSURANCE_PRICE_ID
);
COMMIT;

exception
when invalid_INSURANCE_START_DATE
then
    dbms_output.put_line('Please enter correct INSURANCE start date');
when invalid_INSURANCE_END_DATE
then
    dbms_output.put_line('Please enter correct INSURANCE end date');
when invalid_ORDERS_ID
then
    dbms_output.put_line('Please enter correct ORDERS ID');
when invalid_INSURANCE_PRICE_ID
then
   dbms_output.put_line('Please enter correct INSURANCE PRICE ID');
when others
then dbms_output.put_line('Please enter correct values in INSURANCE Table');
END add_new_INSURANCE;


procedure DROP_record_Insurance (IN_Insurance_ID Insurance.Insurance_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_Insurance_ID exception;
Object_not_found exception;
CURSOR c_Insuranceid is
      select Insurance_id FROM  Insurance; --where  lower(object_name) = 'abcd'    ;

begin
if IN_Insurance_ID <=0
      then
          raise invalid_IN_Insurance_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_Insuranceid;
   LOOP
   FETCH c_Insuranceid into cid;
      EXIT WHEN c_Insuranceid%notfound;   
if (cid =  IN_Insurance_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from Insurance where Insurance_ID = '|| IN_Insurance_ID;
commit;
dbms_output.put_line(IN_Insurance_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_Insuranceid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_Insurance_ID
then dbms_output.put_line ('Please enter valid Insurance_ID');
when Object_not_found
then dbms_output.put_line (IN_Insurance_ID || ' cid not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record_Insurance;


END MANAGE_INSURANCE;
/

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
commit;
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

create or replace PACKAGE MANAGE_OFFERS AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
procedure add_new_OFFERS(

    IN_OFFER_ID OFFERS.OFFER_ID%TYPE,
    IN_OFFER_DESC OFFERS.OFFER_DESC%TYPE,
    IN_CUSTOMER_CATEGORY_ID OFFERS.CUSTOMER_CATEGORY_ID%TYPE
    );

procedure DROP_record_Offers (IN_Offer_ID Offers.Offer_ID%type );

END MANAGE_OFFERS;
/
create or replace PACKAGE BODY MANAGE_OFFERS  AS



  /* TODO enter package declarations (types, exceptions, methods etc) here */



procedure add_new_OFFERS(
    IN_OFFER_ID OFFERS.OFFER_ID%TYPE,
    IN_OFFER_DESC OFFERS.OFFER_DESC%TYPE,
    IN_CUSTOMER_CATEGORY_ID OFFERS.CUSTOMER_CATEGORY_ID%TYPE
    )



as



invalid_IN_OFFER_ID exception;
invalid_IN_OFFER_DESC exception;
invalid_IN_CUSTOMER_CATEGORY_ID exception;



BEGIN
  if IN_OFFER_ID <=0
then  raise invalid_IN_OFFER_ID; 
 elsif length(IN_OFFER_DESC) <=0
then raise invalid_IN_OFFER_DESC; 
elsif IN_CUSTOMER_CATEGORY_ID <=0
then raise invalid_IN_CUSTOMER_CATEGORY_ID;    
 end if;



insert into OFFERS(
OFFER_ID,
OFFER_DESC,
CUSTOMER_CATEGORY_ID
)
values(



IN_OFFER_ID,
IN_OFFER_DESC,
IN_CUSTOMER_CATEGORY_ID
);
commit;

  
exception
when invalid_IN_OFFER_ID
then
    dbms_output.put_line('Please enter correct OFFER_ID');
when invalid_IN_OFFER_DESC
then dbms_output.put_line('Please enter correct values for OFFER_DESC');
when invalid_IN_CUSTOMER_CATEGORY_ID
then dbms_output.put_line('Please enter correct values for CUSTOMER_CATEGORY_ID');
when others
then dbms_output.put_line('Please enter correct values in OFFERS TABLE');



END add_new_OFFERS;


procedure DROP_record_Offers (IN_Offer_ID Offers.Offer_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_Offer_ID exception;
Object_not_found exception;
CURSOR c_Offersid is
      select Offer_ID FROM  Offers; --where  lower(object_name) = 'abcd'    ;

begin
if IN_Offer_ID <=0
      then
          raise invalid_IN_Offer_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_Offersid;
   LOOP
   FETCH c_Offersid into cid;
      EXIT WHEN c_Offersid%notfound;   
if (cid =  IN_Offer_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from Offers where Offer_ID = '|| IN_Offer_ID;
commit;
dbms_output.put_line(IN_Offer_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_Offersid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_Offer_ID
then dbms_output.put_line ('Please enter valid Offer_ID');
when Object_not_found
then dbms_output.put_line (IN_Offer_ID || ' cid not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record_Offers;



END MANAGE_OFFERS;
/

create or replace PACKAGE MANAGE_WARRANTY AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_WARRANTY(
   
    IN_PRODUCT_ID WARRANTY.PRODUCT_ID%TYPE,
    IN_ORDERS_ID WARRANTY.ORDERS_ID%TYPE,
    IN_START_DATE  WARRANTY.START_DATE%TYPE,
    IN_END_DATE  WARRANTY.END_DATE%TYPE
    );

procedure DROP_record_Warranty (IN_Warranty_ID Warranty.Warranty_ID%type );
END MANAGE_WARRANTY;
/

create or replace PACKAGE BODY MANAGE_WARRANTY AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure add_new_WARRANTY(
    IN_PRODUCT_ID WARRANTY.PRODUCT_ID%TYPE,
    IN_ORDERS_ID WARRANTY.ORDERS_ID%TYPE,
    IN_START_DATE  WARRANTY.START_DATE%TYPE,
    IN_END_DATE  WARRANTY.END_DATE%TYPE
    )
AS
   invalid_PRODUCT_ID exception;
    invalid_BILL_NO exception;
    invalid_START_DATE exception;
    invalid_END_DATE exception;
   
BEGIN
if IN_PRODUCT_ID <=0
      then
        raise invalid_PRODUCT_ID ;     
    
  elsif IN_ORDERS_ID <=0
      then
          raise invalid_BILL_NO ;      
   
  elsif length(IN_START_DATE) <=0
      then
          raise invalid_START_DATE ;     
    
  elsif length(IN_END_DATE) <=0
      then
          raise invalid_END_DATE ;        
    end if;
   
Insert into WARRANTY (
    WARRANTY_ID,
    PRODUCT_ID,
    ORDERS_ID,
    START_DATE,
    END_DATE
)
values(
    war_seq.currval,
    IN_PRODUCT_ID,
    IN_ORDERS_ID,
    IN_START_DATE,
    IN_END_DATE
);
commit;

exception
when invalid_PRODUCT_ID
then
    dbms_output.put_line('Please enter correct product ID');
when invalid_BILL_NO
then
    dbms_output.put_line('Please enter correct bill no');
when invalid_START_DATE
then
    dbms_output.put_line('Please enter correct start date');
when invalid_END_DATE
then
    dbms_output.put_line('Please enter correct end date');
when others
then dbms_output.put_line('Please enter correct values in WARRANTY Table');
END add_new_warranty;


procedure DROP_record_Warranty (IN_Warranty_ID Warranty.Warranty_ID%type )
as
cid number ;
IS_TRUE  number;
invalid_IN_Warranty_ID exception;
Object_not_found exception;
CURSOR c_Warrantyid is
      select Warranty_ID FROM  Warranty; --where  lower(object_name) = 'abcd'    ;

begin
if IN_Warranty_ID <=0
      then
          raise invalid_IN_Warranty_ID;      
    end if;
            
   IS_TRUE:= 0;     
OPEN c_Warrantyid;
   LOOP
   FETCH c_Warrantyid into cid;
      EXIT WHEN c_Warrantyid%notfound;   
if (cid =  IN_Warranty_ID)
then
dbms_output.put_line ('it has come inside loop');
execute immediate 'delete from Warranty where Warranty_ID = '|| IN_Warranty_ID;
commit;
dbms_output.put_line(IN_Warranty_ID || ' is deleted' );
IS_TRUE := 1;
end if;
end loop;
close c_Warrantyid;

if IS_TRUE = 0 then raise Object_not_found ;
   end if;
  
exception
when invalid_IN_Warranty_ID
then dbms_output.put_line ('Please enter valid Warranty_ID');
when Object_not_found
then dbms_output.put_line (IN_Warranty_ID || ' order id not found');
when others
then dbms_output.put_line(sqlerrm);


end DROP_record_Warranty;


END MANAGE_WARRANTY;
/




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
elsif (IN_ord_qty > v_remaining_qty or IN_ord_qty = 0)
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
commit;
update product
set qty_per_unit = qty_per_unit - IN_ord_qty
where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));
commit;
select PRODUCT_ID into pid from PRODUCT where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));
v_oid := ORDER_seq.currval;
MANAGE_WARRANTY.add_new_WARRANTY(pid,v_oid,sysdate,add_months(sysdate,3));
commit;
MANAGE_COURIER.add_new_COURIER(v_oid,'UPS','In Transit','Y');
commit;
select Insurance_price_id into v_ins_price from INSURANCE_PRICE where product_id = pid  ;
    --dbms_output.put_line(length(pid)||pid); 
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
commit;
execute immediate 'delete from insurance where orders_ID = '|| IN_orders_ID;
commit;
else
update orders
set order_qty=order_qty-In_cancelation_qty,
ORDER_PRICE = ORDER_PRICE - cancelled_ord_price
where orders_id = v_orders_ID;
commit;
end if;

if (v_can_ord_qty=0)
then
update warranty
set start_date = '',
ENd_date = ''
where orders_id = v_orders_ID;
commit;
end if;

update product
set QTY_PER_UNIT = QTY_PER_UNIT + In_cancelation_qty
where PRODUCT_NAME = IN_PRODUCT_NAME;
commit;
if (v_ord_qty = In_cancelation_qty)
then update courier
    set DELIVERY_STATUS = 'cancelled'
    where orders_id = v_orders_ID;
    commit;
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
commit;
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
create or replace PACKAGE CLAIM_MANAGER AS

procedure resolve_CLAIM(

IN_claim_ID claim.claim_ID%type

);


END CLAIM_MANAGER;

/

create or replace PACKAGE BODY CLAIM_MANAGER AS

procedure resolve_CLAIM(

IN_claim_ID claim.claim_ID%type

)

as

cursor c_claim is

        select claim_ID, orders_ID, warranty_ID,insurance_id ,issue_date, resolve_date from claim;

v_claim_ID number;

v_orders_ID number;

v_Warranty_ID number;

v_insurance_ID number;

v_issue_date date;

v_resolve_date date;

IS_CLAIM_TRUE number := 0;

invalid_Claim_ID exception;

resolved_claim exception;



BEGIN

OPEN c_claim;

   LOOP

   FETCH c_claim into v_claim_ID, v_orders_ID,v_Warranty_ID,v_insurance_ID,v_issue_date,v_resolve_date;

      EXIT WHEN c_claim%notfound;

if (v_claim_ID = in_claim_ID)

then

dbms_output.put_line ('it has come inside claim loop');

IS_CLAIM_TRUE := 1;

EXIT;

end if;

end loop;

close c_claim;



if IS_CLAIM_TRUE = 0

then raise invalid_Claim_ID;

end if;



if  (IS_CLAIM_TRUE =1 and v_resolve_date <> '31-DEC-9999')

then raise resolved_claim;

elsif  (IS_CLAIM_TRUE =1 and v_insurance_ID is not null)

then update claim

set resolve_date = sysdate

where claim.issue_date < (select insurance_end_date

from insurance where insurance_ID = v_insurance_ID )

and claim_ID = IN_claim_ID;
commit;

elsif (v_insurance_ID is null)

then dbms_output.put_line('this is to let you know that claim is not covered under insurance, please make the payment');

end if;



EXCEPTION

when invalid_Claim_ID

then dbms_output.put_line('entered claim# '|| in_claim_ID || ' does not exist');

when resolved_claim

then dbms_output.put_line('entered claim# '|| in_claim_ID || ' is already resolved');

when others

then dbms_output.put_line(sqlerrm);

END resolve_CLAIM;

END CLAIM_MANAGER;

/

create or replace PACKAGE COURIER_MANAGER AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
 procedure courier_delivered(

     IN_COURIER_ID courier.COURIER_ID%type

     );


END COURIER_MANAGER;

/

create or replace PACKAGE BODY COURIER_MANAGER AS 


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
commit;

dbms_output.put_line(v_product_name || ' is delivered for order#' ||v_ordes_ID);

end if;



commit;



EXCEPTION

when Invalid_courier_ID

then dbms_output.put_line('Enter correct courier ID');

when others

then dbms_output.put_line(sqlerrm);



END courier_delivered;

END COURIER_MANAGER;

/

create or replace PACKAGE CUST_MANAGE_ORDER_CLAIM AS 

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
   procedure add_new_CLAIM(

    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE,

    IN_ORDERS_ID CLAIM.ORDERS_ID%TYPE,

    IN_WARRANTY_ID CLAIM.WARRANTY_ID%TYPE,

    IN_INSURANCE_ID CLAIM.INSURANCE_ID%TYPE

    );

END CUST_MANAGE_ORDER_CLAIM;

/

create or replace PACKAGE BODY CUST_MANAGE_ORDER_CLAIM AS 

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

elsif (IN_ord_qty > v_remaining_qty or IN_ord_qty = 0)

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

commit;

update product

set qty_per_unit = qty_per_unit - IN_ord_qty

where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));


commit;
select PRODUCT_ID into pid from PRODUCT where lower(trim(PRODUCT.PRODUCT_NAME)) = lower(trim(IN_PRODUCT_NAME));

v_oid := ORDER_seq.currval;

MANAGE_WARRANTY.add_new_WARRANTY(pid,v_oid,sysdate,add_months(sysdate,3));
commit;
MANAGE_COURIER.add_new_COURIER(v_oid,'UPS','In Transit','Y');
commit;


select Insurance_price_id into v_ins_price from INSURANCE_PRICE where product_id = pid  ;

    --dbms_output.put_line(length(pid)||pid); 

if IN_INSURANCE_STATUS = 'Y'

then MANAGE_INSURANCE.add_new_INSURANCE(sysdate,add_months(sysdate,12),v_oid,v_ins_price);
commit;
end if;





end if;

commit;

dbms_output.put_line('Order# '||v_oid || ' placed for '|| IN_PRODUCT_NAME|| ' by user ' || IN_CUSTOMER_FNAME);



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
commit;
execute immediate 'delete from insurance where orders_ID = '|| IN_orders_ID;
commit;
else

update orders

set order_qty=order_qty-In_cancelation_qty,

ORDER_PRICE = ORDER_PRICE - cancelled_ord_price

where orders_id = v_orders_ID;
commit;
end if;



if (v_can_ord_qty=0)

then

update warranty

set start_date = '',

ENd_date = ''

where orders_id = v_orders_ID;
commit;
end if;



update product

set QTY_PER_UNIT = QTY_PER_UNIT + In_cancelation_qty

where PRODUCT_NAME = IN_PRODUCT_NAME;
commit;
if (v_ord_qty = In_cancelation_qty)

then update courier

    set DELIVERY_STATUS = 'cancelled'

    where orders_id = v_orders_ID;
commit;
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

procedure add_new_CLAIM (

    IN_CLAIM_DESCRIPTION CLAIM_CATEGORY.CLAIM_DESCRIPTION%TYPE,

    IN_ORDERS_ID CLAIM.ORDERS_ID%TYPE,

    IN_WARRANTY_ID CLAIM.WARRANTY_ID%TYPE,

    IN_INSURANCE_ID CLAIM.INSURANCE_ID%TYPE

    )

AS

   invalid_CLAIM_DESCRIPTION exception;

    invalid_ORDERS_ID exception;

    invalid_WARRANTY_ID exception;

    invalid_INSURANCE_ID exception;

    claimAlreadyExists exception;

    v_orders_ID number;

    v_warranty_ID number;

    v_insurance_ID number;

    v_claim_category_id number;

    v_cl_claim_ID number;

    v_cl_orders_ID number;

    IS_ORD_TRUE number :=0;

    IS_WAR_TRUE number :=0;

    IS_INS_TRUE number :=0;

    IS_claimcat_TRUE number :=0;

    IS_INS_PURCCHASED number;

    v_ins_status varchar(3);

    CURSOR c_orderdetail is

      select  o.orders_ID,o.warranty_ID,i.insurance_ID,o.insurance_status

      from  insurance i right join orders o on i.orders_id = o.orders_id where ORDER_QTY <> 0;

    cursor c_claim is

        select claim_category_id from claim_category where lower(trim(claim_description)) = lower(trim(IN_CLAIM_DESCRIPTION)) ;

    cursor c_claimAlreadyExists is

        select claim_ID, orders_ID from claim;



BEGIN





OPEN c_orderdetail;

   LOOP

   FETCH c_orderdetail into v_orders_ID, v_warranty_ID,v_insurance_ID,v_ins_status;

      EXIT WHEN c_orderdetail%notfound;

if (v_warranty_ID =  IN_WARRANTY_ID)

then

dbms_output.put_line ('it has come inside orderdetail war loop');

IS_WAR_TRUE := 1;

end if;

if ( v_orders_ID = IN_orders_id)

then

dbms_output.put_line ('it has come inside orderdetail ord loop');

IS_ORD_TRUE := 1;

end if;

if ( (v_INSURANCE_ID = IN_INSURANCE_id) or (trim(upper(v_ins_status)) = 'N' and v_orders_ID = IN_orders_id) )

then

dbms_output.put_line ('it has come inside orderdetail ins loop');

IS_INS_TRUE := 1;

exit;

end if;

end loop;

close c_orderdetail;



OPEN c_claim;

   LOOP

   FETCH c_claim into v_claim_category_id;

      EXIT WHEN c_claim%notfound;

if (v_claim_category_id <> 0)

then

dbms_output.put_line ('it has come inside claim loop');

IS_claimcat_TRUE := 1;

end if;

end loop;

close c_claim;



OPEN c_claimAlreadyExists;

   LOOP

   FETCH c_claimAlreadyExists into v_cl_claim_ID, v_cl_orders_ID;

      EXIT WHEN c_claimAlreadyExists%notfound;

if (v_cl_orders_ID = IN_ORDERS_ID)

then

dbms_output.put_line ('it has come inside claimAlreadyExists loop');

raise claimAlreadyExists;

end if;

end loop;

close c_claimAlreadyExists;



  if (length(IN_CLAIM_DESCRIPTION) <=0 or IS_claimcat_TRUE = 0)

      then

          raise invalid_CLAIM_DESCRIPTION ;     



  elsif (IN_ORDERS_ID <=0 or IS_ORD_TRUE = 0)

      then

          raise invalid_ORDERS_ID ;     





  elsif (IN_WARRANTY_ID <=0 or IS_WAR_TRUE = 0)

      then

          raise invalid_WARRANTY_ID ;     



  elsif (IN_INSURANCE_ID<=0 or IS_INS_TRUE = 0)

      then

          raise invalid_INSURANCE_ID ;     

    end if;



insert into claim(

claim_id,

CLAIM_CATEGORY_ID,

ORDERS_ID,

WARRANTY_ID,

ISSUE_DATE,

RESOLVE_DATE,

INSURANCE_ID

)

values(

CLAIM_SEQ.NEXTVAL,

v_claim_category_id,

v_orders_ID,

v_warranty_ID,

sysdate ,

'31-DEC-9999',

v_insurance_ID

);

commit;
exception

when invalid_CLAIM_DESCRIPTION

then

    dbms_output.put_line('Please enter correct claim Description');

when invalid_ORDERS_ID

then

    dbms_output.put_line('Please enter correct order_id');

when invalid_WARRANTY_ID

then

    dbms_output.put_line('Please enter correct warranty id');

when invalid_INSURANCE_ID

then

    dbms_output.put_line('Please enter correct insurance id');

when claimAlreadyExists

then dbms_output.put_line('claim#' || v_cl_claim_ID || 'already exists for order#'||v_cl_orders_ID);

when others

then dbms_output.put_line(sqlerrm);



END add_new_claim;

END CUST_MANAGE_ORDER_CLAIM;

/


exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Phone');
exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Laptop');
exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Earphones');
exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Ipad');
exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Charging cable');
exec MANAGE_INVENTORY.add_new_PRODUCT_CATEGORY('Adaptor');

exec MANAGE_INVENTORY.add_new_product('Iphone 9',4001,1000,900,'Y');
exec MANAGE_INVENTORY.add_new_product('Macbook',4002,32,1200,'Y');
exec MANAGE_INVENTORY.add_new_product('Airpods',4003,500,200,'Y');
exec MANAGE_INVENTORY.add_new_product('Ipad',4004,12,1100,'Y');
exec MANAGE_INVENTORY.add_new_product('Airpods Pro',4003,500,250,'Y');
exec MANAGE_INVENTORY.add_new_product('Ipad Gen 2',4004,500,1400,'Y');
exec MANAGE_INVENTORY.add_new_product('Lightning cable (1m)',4005,250,20,'Y');
exec MANAGE_INVENTORY.add_new_product('USB-C Power Adaptor',4006,650,20,'Y');
exec MANAGE_INVENTORY.add_new_product('Iphone 10',4001,500,1200,'Y');
exec MANAGE_INVENTORY.add_new_product('Iphone 13',4001,50,1200,'Y');

exec MANAGE_CUSTOMERS.add_new_CUSTOMER_CATEGORY('Student');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER_CATEGORY('Veteran');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER_CATEGORY('Employee');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER_CATEGORY('Senior_Citizen');

exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2001,'Alex','Pinto','Boston',8576939855,'Alex@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2001,'Jack','Brown','New York',9419202150,'Jack@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2002,'Meena','Kumari','Boston',1234567890,'Meena@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2003,'Rekha','Bachhan','Boston',9876543210,'Rekha@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2002,'Andy','Deb','New York',8576939833,'Andy@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2001,'Akhil','Talashi','California',8676939835,'Akhil@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2003,'Mital','Bhanushali','New Jersey',8123439833,'Mital@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2004,'Rutuja','Ghate','Boston',2130120310,'Rutuja@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2002,'Yash','Kumar','Atlanta',9876543536,'Yash@gmail.com');
exec MANAGE_CUSTOMERS.add_new_CUSTOMER(2004,'Danish','Parkar','Boston',9876544200,'Danish@gmail.com');

exec MANAGE_OFFERS.add_new_OFFERS(50,'50% Discount',2001);
exec MANAGE_OFFERS.add_new_OFFERS(20,'20% Discount',2002);
exec MANAGE_OFFERS.add_new_OFFERS(30,'30% Discount',2003);
exec MANAGE_OFFERS.add_new_OFFERS(40,'40% Discount',2004);


exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5001,4001,50);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5002,4002,100);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5003,4003,30);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5004,4004,80);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5005,4005,5);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5006,4006,8);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5007,4005,5);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5008,4003,30);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5009,4002,100);
exec MANAGE_INSURANCE.add_new_INSURANCE_PRICE(5010,4004,80);

exec MANAGE_CLAIM.add_new_CLAIM_CATEGORY('Cracked screen');
exec MANAGE_CLAIM.add_new_CLAIM_CATEGORY('Accidental body damage');
exec MANAGE_CLAIM.add_new_CLAIM_CATEGORY('loss and theft');


--USERS & ROLES  
--APP_ADMIN_MITAL  
--GRANT ALL ACCESS  ***************************  
--create user App_admin_mital identified by November2022 DEFAULT TABLESPACE data_ts QUOTA UNLIMITED ON data_ts ;  
--GRANT CONNECT TO APP_ADMIN_MITAL;  
--grant create view, create procedure, create sequence, CREATE USER to APP_ADMIN_MITAL with admin option;  
--GRANT CONNECT, RESOURCE TO App_admin_mital with admin option;  *********************
--grant create session grant any privilege to APP_ADMIN_MITAL;   
--CUSTOMER --GRANT ACCESS TO PACKAGE - CUST_MANAGE_ORDER_CLAIM --CUSTOMER ALEX  
create user ALEX identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO ALEX;  
--GRANT CONNECT, RESOURCE TO ALEX;  
GRANT execute on APP_ADMIN_MITAL.CUST_MANAGE_ORDER_CLAIM to ALEX;   
--CUSTOMER YASH  
create user YASH identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO YASH;  
--GRANT CONNECT, RESOURCE TO YASH;  
GRANT execute on APP_ADMIN_MITAL.CUST_MANAGE_ORDER_CLAIM to YASH;   
--CUSTOMER JACK  
create user JACK identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO JACK;  
--GRANT CONNECT, RESOURCE TO JACK;  
GRANT execute on APP_ADMIN_MITAL.CUST_MANAGE_ORDER_CLAIM to JACK;   
--CUSTOMER MEENA  
create user MEENA identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO MEENA;  
--GRANT CONNECT, RESOURCE TO MEENA;  
GRANT execute on APP_ADMIN_MITAL.CUST_MANAGE_ORDER_CLAIM to MEENA;   
--Claim Manager  --GRANT ACCESS TO PACKAGE - CLAIM_MANAGER   --GRANT FOLLOWING View Access OF TABLES --Insurance TABLE --Warranty TABLE     
create user CLAIM_MANAGER_ADMIN identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO CLAIM_MANAGER_ADMIN;  
--GRANT CONNECT, RESOURCE TO CLAIM_MANAGER_ADMIN;  
GRANT execute on APP_ADMIN_MITAL.CLAIM_MANAGER to CLAIM_MANAGER_ADMIN;   
--Courier Manager  --GRANT ACCESS TO PACKAGE - COURIER_MANAGER    
create user COURIER_MANAGER_ADMIN identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO COURIER_MANAGER_ADMIN;  
--GRANT CONNECT, RESOURCE TO COURIER_MANAGER_ADMIN;  
GRANT execute on APP_ADMIN_MITAL.COURIER_MANAGER to COURIER_MANAGER_ADMIN;   
--SALES MANAGER   ---GRANT ACCESS TO SALES REPORT VIEWS    
create user SALES_MANAGER_ADMIN identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO SALES_MANAGER_ADMIN;  
--GRANT CONNECT, RESOURCE TO SALES_MANAGER_ADMIN;   
--INVENTORY MANAGER   --GRANT ACCESS TO MANAGE_INVENTORY    
create user INVENTORY_MANAGER_ADMIN identified by November2022 DEFAULT TABLESPACE data_ts QUOTA 5G ON data_ts ;  
GRANT CONNECT TO INVENTORY_MANAGER_ADMIN;  
--GRANT CONNECT, RESOURCE TO INVENTORY_MANAGER_ADMIN;  
GRANT execute on APP_ADMIN_MITAL.MANAGE_INVENTORY to INVENTORY_MANAGER_ADMIN;             


