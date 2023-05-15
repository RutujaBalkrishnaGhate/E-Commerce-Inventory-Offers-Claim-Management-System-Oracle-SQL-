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

 

 

Commit;

 

 

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
