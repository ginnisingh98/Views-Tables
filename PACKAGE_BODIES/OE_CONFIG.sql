--------------------------------------------------------
--  DDL for Package Body OE_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG" AS
/* $Header: oexczdfb.pls 115.8 2000/02/16 18:31:10 pkm ship    $ */


function CZ_BCE_DETAILS_FLAG(comp_common_bill_sequence_id IN NUMBER)
   RETURN VARCHAR2
IS
        CURSOR details(comp_common_bill_sequence_id NUMBER) IS

        select 'Y'
        from   bom_inventory_components bic
        where  bic.bill_sequence_id = comp_common_bill_sequence_id
        and    (bic.bom_item_type = 1
                or bic.bom_item_type = 2
                or (bic.optional = 1 and bic.bom_item_type = 4)
               );

--The cursor "details" has been changed to resolve the issue where "+" signs were
--not being displayed in the config window for mandatory option classes having
--optional items under it (bug #615826). The previous sql used to look at the
--immediate children of the referenced item. It has been changed to look all
--the way down the tree.

/*        select 'Y'
        from   bom_bill_of_materials bom
        where  bom.assembly_item_id (+) = assembly_id
        and    bom.organization_id = org_id
        and    nvl(bom.alternate_bom_designator,'-99') = nvl(alt_desg,'-99')
        and    exists (select 'Exists'
                      from   bom_inventory_components bic
                      where  bic.bill_sequence_id = bom.common_bill_sequence_id
                      and    optional = 1);*/

        details_flag VARCHAR2(15) := 'N';
   BEGIN
        OPEN details(comp_common_bill_sequence_id);
        FETCH details into details_flag;
        IF SQL%NOTFOUND THEN
          details_flag := 'N';
        END IF;
        CLOSE details;

        return(details_flag);
   END CZ_BCE_DETAILS_FLAG;


FUNCTION cz_get_list_price( component_item_id IN NUMBER,
                        primary_uom_code IN VARCHAR2,
                        list_id IN NUMBER,
			prc_attr1 IN VARCHAR2 DEFAULT NULL,
			prc_attr2 IN VARCHAR2 DEFAULT NULL,
			prc_attr3 IN VARCHAR2 DEFAULT NULL,
			prc_attr4 IN VARCHAR2 DEFAULT NULL,
			prc_attr5 IN VARCHAR2 DEFAULT NULL,
			prc_attr6 IN VARCHAR2 DEFAULT NULL,
			prc_attr7 IN VARCHAR2 DEFAULT NULL,
			prc_attr8 IN VARCHAR2 DEFAULT NULL,
			prc_attr9 IN VARCHAR2 DEFAULT NULL,
			prc_attr10 IN VARCHAR2 DEFAULT NULL,
			prc_attr11 IN VARCHAR2 DEFAULT NULL,
			prc_attr12 IN VARCHAR2 DEFAULT NULL,
			prc_attr13 IN VARCHAR2 DEFAULT NULL,
			prc_attr14 IN VARCHAR2 DEFAULT NULL,
			prc_attr15 IN VARCHAR2 DEFAULT NULL)

RETURN NUMBER
IS
--****************************************************************************
-- This function is used to populate the list price of an item in the config window.
-- It checks for the list price in the following places in the following order:
-- 1. The primary price list with the pricing attributes on the price list
--    matching the pricing attributes on the line.
-- 2. The primary price list without checking if the attributes match.
-- 3. The list price on the item.
--*****************************************************************************

   CURSOR price(component_item_id NUMBER,
                primary_uom_code VARCHAR2,
                x_price_list_id NUMBER,
		prc_attr1 VARCHAR2,
		prc_attr2  VARCHAR2,
		prc_attr3  VARCHAR2,
		prc_attr4  VARCHAR2,
		prc_attr5  VARCHAR2,
		prc_attr6  VARCHAR2,
		prc_attr7  VARCHAR2,
		prc_attr8  VARCHAR2,
		prc_attr9  VARCHAR2,
		prc_attr10  VARCHAR2,
		prc_attr11  VARCHAR2,
		prc_attr12  VARCHAR2,
		prc_attr13  VARCHAR2,
		prc_attr14  VARCHAR2,
		prc_attr15  VARCHAR2) IS
   SELECT  NVL(PRL.LIST_PRICE,SEL.LIST_PRICE)
     FROM    SO_PRICE_LISTS PRI
         ,   SO_PRICE_LIST_LINES PRL
         ,   SO_PRICE_LISTS SEC
         ,   SO_PRICE_LIST_LINES SEL
     WHERE   PRL.INVENTORY_ITEM_ID (+)= component_item_id
       AND    PRL.UNIT_CODE (+)=  primary_uom_code
       AND    PRL.PRICE_LIST_ID (+) +0  = PRI.PRICE_LIST_ID
       AND    TRUNC(SYSDATE) BETWEEN NVL(PRL.START_DATE_ACTIVE(+),TRUNC(SYSDATE))
             AND NVL(PRL.END_DATE_ACTIVE(+),TRUNC(SYSDATE))
       AND    PRI.PRICE_LIST_ID = x_price_list_id
       AND    TRUNC(SYSDATE) BETWEEN NVL(PRI.START_DATE_ACTIVE,TRUNC(SYSDATE))
             AND NVL(PRI.END_DATE_ACTIVE,TRUNC(SYSDATE))
       AND    SEL.INVENTORY_ITEM_ID (+)= component_item_id
       AND    SEL.UNIT_CODE (+)= primary_uom_code
       AND    TRUNC(SYSDATE) BETWEEN NVL(SEL.START_DATE_ACTIVE(+),TRUNC(SYSDATE))
              AND NVL(SEL.END_DATE_ACTIVE(+),TRUNC(SYSDATE))
       AND    SEC.PRICE_LIST_ID = NVL(PRI.SECONDARY_PRICE_LIST_ID,
                                    PRI.PRICE_LIST_ID)
       AND    TRUNC(SYSDATE) BETWEEN NVL(SEC.START_DATE_ACTIVE,TRUNC(SYSDATE))
              AND NVL(SEC.END_DATE_ACTIVE,TRUNC(SYSDATE))
       AND    SEL.PRICE_LIST_ID (+) +0  = SEC.PRICE_LIST_ID
       --AND    NVL(PRL.PRICING_CONTEXT,' ') = ' '
       AND    NVL(PRL.PRICING_ATTRIBUTE1,'NULL') = NVL(prc_attr1, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE2,'NULL') = NVL(prc_attr2, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE3,'NULL') = NVL(prc_attr3, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE4,'NULL') = NVL(prc_attr4, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE5,'NULL') = NVL(prc_attr5, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE6,'NULL') = NVL(prc_attr6, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE7,'NULL') = NVL(prc_attr7, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE8,'NULL') = NVL(prc_attr8, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE9,'NULL') = NVL(prc_attr9, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE10,'NULL') = NVL(prc_attr10, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE11,'NULL') = NVL(prc_attr11, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE12,'NULL') = NVL(prc_attr12, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE13,'NULL') = NVL(prc_attr13, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE14,'NULL') = NVL(prc_attr14, 'NULL')
       AND    NVL(PRL.PRICING_ATTRIBUTE15,'NULL') = NVL(prc_attr15, 'NULL')
       --AND    NVL(SEL.PRICING_CONTEXT,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE1,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE2,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE3,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE4,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE5,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE6,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE7,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE8,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE9,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE10,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE11,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE12,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE13,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE14,' ') = ' '
       --AND    NVL(SEL.PRICING_ATTRIBUTE15,' ') = ' '
	;

     CURSOR dummy_price(component_item_id NUMBER) IS
	select LIST_PRICE_PER_UNIT
	from mtl_system_items_kfv msi
	where msi.inventory_item_id = component_item_id;

     x_list_price NUMBER ;

BEGIN

       if (list_id is NULL) then
          return(0);
       end if;
       open dummy_price(component_item_id);
       fetch dummy_price into x_list_price;
       if dummy_price%NOTFOUND then
		x_list_price := 0;
       end if;
       close dummy_price;

       open price(component_item_id,
                primary_uom_code,
                list_id,
		prc_attr1,
		prc_attr2,
		prc_attr3,
		prc_attr4,
		prc_attr5,
		prc_attr6,
		prc_attr7,
		prc_attr8,
		prc_attr9,
		prc_attr10,
		prc_attr11,
		prc_attr12,
		prc_attr13,
		prc_attr14,
		prc_attr15);

	FETCH price into x_list_price;
	IF price%NOTFOUND THEN
		CLOSE price;
		OPEN price(component_item_id,
                	primary_uom_code,
                	list_id,
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL',
			'NULL');
		FETCH price into x_list_price;
		IF price%NOTFOUND THEN
			CLOSE price;
			return(x_list_price);
		END IF;
	ELSE
		CLOSE price;
		return(x_list_price);
	END IF;
      return(x_list_price);
END cz_get_list_price;


function CZ_MESSAGE_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;
   BEGIN
        return(x_count);
   END CZ_MESSAGE_COUNT;

function CZ_ERROR_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;
   BEGIN

        return(x_count);

   END CZ_ERROR_COUNT;

function CZ_AUTOSELECT_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;
   BEGIN

        return(x_count);

   END CZ_AUTOSELECT_COUNT;

function CZ_OVERRIDE_ERROR_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;
   BEGIN

        return(x_count);

   END CZ_OVERRIDE_ERROR_COUNT;

function CZ_OVERRIDEN_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;
   BEGIN

        return(x_count);

   END CZ_OVERRIDEN_COUNT;


function CZ_WARN_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is

        x_count number := 0;
   BEGIN
        return(x_count);
   END CZ_WARN_COUNT;

function CZ_SUGGEST_COUNT(x_system_id   IN NUMBER,
                        x_header_id   IN NUMBER,
                        x_line_id     IN NUMBER)
   RETURN NUMBER
is
        x_count number := 0;

   BEGIN
        return(x_count);
   END CZ_SUGGEST_COUNT;


END OE_CONFIG;

/
