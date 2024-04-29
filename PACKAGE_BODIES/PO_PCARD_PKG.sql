--------------------------------------------------------
--  DDL for Package Body PO_PCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PCARD_PKG" AS
/* $Header: POPCARDB.pls 120.0 2005/06/01 15:49:28 appldev noship $ */
/* Contains the functions that are used to support supplier and employee
 * pcards*/

/* is_pcard_valid_and_active returns true if the pcard_id is active and not
 * expired. If it is inactive or expired then return false.
*/
function is_pcard_valid_and_active(x_pcard_id in number) return boolean is
x_valid number :=0;
begin
        	begin
	        	select 1
                	into x_valid
                	from ap_cards ac
               	 	where ac.card_id = x_pcard_id
                	and (card_expiration_date is null or
               	 	card_expiration_date >= trunc(sysdate))         -- <HTMLAC>
                	and (INACTIVE_DATE is null or
                	INACTIVE_DATE >= trunc(sysdate) );              -- <HTMLAC>

                	return TRUE; /* It is active and not expired */
       	 exception
                	when no_data_found then
                        	return FALSE; /* It is either expired or inactive*/
			when others then
				raise;
	end;

end is_pcard_valid_and_active;

-----------------------------------------------------------------------<HTMLAC>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_pcard_valid_active_tbl
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Bulk version of is_pcard_valid_and_active function. Takes in a table of
--  P-Card IDs and returns a table 'Y' and 'N' indicating whether the
--  corresponding ID in the input table is a valid and active P-Card.
--Parameters:
--IN:
--p_pcard_id_tbl
--  PO_TBL_NUMBER consisting of P-Card IDs to validate
--Returns:
--  PO_TBL_VARCHAR1 consisting of 'Y' or 'N' indicating whether the
--  corresponding ID in the input table is a valid and active P-Card.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_pcard_valid_active_tbl
(
    p_pcard_id_tbl    IN    PO_TBL_NUMBER
)
RETURN PO_TBL_VARCHAR1
IS
    l_result_tbl          PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
    l_valid_pcard_id_tbl  PO_TBL_NUMBER := PO_TBL_NUMBER();
    l_key                 NUMBER;
    l_pcard_id            NUMBER;
    l_pcard_is_valid      BOOLEAN;
    l_valid_pcards_exist  BOOLEAN := false;

BEGIN

    l_result_tbl.extend(p_pcard_id_tbl.COUNT);


    -- Populate GT Table ------------------------------------------------------

    l_key := PO_CORE_S.get_session_gt_nextval;

    FORALL i IN 1..p_pcard_id_tbl.COUNT
        INSERT INTO po_session_gt
        ( key
        , index_num1
        )
        VALUES
        ( l_key
        , p_pcard_id_tbl(i)
        );

    -- Execute Query ----------------------------------------------------------

    -- Retrieve all IDs of P-Cards which are in the GT Table and are
    -- valid (card_expiration_date) and active (inactive_date).
    --
    SELECT ac.card_id
    BULK COLLECT
    INTO   l_valid_pcard_id_tbl
    FROM   ap_cards_all    ac
    ,      po_session_gt   gt
    WHERE  ac.card_id = gt.index_num1        -- select only P-cards in GT table
    AND    gt.key = l_key                    -- which we inserted above
    AND    (   ( ac.card_expiration_date IS NULL )
           OR  ( ac.card_expiration_date >= trunc(sysdate) ) )
    AND    (   ( ac.inactive_date IS NULL )
           OR  ( ac.inactive_date >= trunc(sysdate) ) );

    -- Set the l_valid_pcards_exist flag if the above query returned any rows.
    --
    IF ( l_valid_pcard_id_tbl.COUNT > 0 )
    THEN
        l_valid_pcards_exist := true;
    END IF;


    -- Clean Up GT Table ------------------------------------------------------

    -- Delete all records that we inserted into the GT table.
    --
    DELETE FROM po_session_gt gt
	WHERE       gt.key = l_key;


    -- Filter Results ---------------------------------------------------------

    -- Loop through initial input list of P-Card IDs.
    --
    FOR i IN p_pcard_id_tbl.FIRST..p_pcard_id_tbl.LAST
    LOOP

        l_pcard_is_valid := false;              -- initialize flag to false
        l_pcard_id := p_pcard_id_tbl(i);        -- current P-Card

        -- Loop through all valid P-Cards to see if the current
        -- P-Card exists in the table (only if there exist any valid P-Cards).
        --
        IF ( l_valid_pcards_exist )
        THEN

            FOR j IN l_valid_pcard_id_tbl.FIRST..l_valid_pcard_id_tbl.LAST
            LOOP
                IF ( l_pcard_id = l_valid_pcard_id_tbl(j) ) -- if P-Card found,
                THEN                                        -- mark valid flag
                    l_pcard_is_valid := true;
                END IF;
            END LOOP;

        END IF; -- ( l_valid_pcards_exist )

        -- Set result table entry to either 'Y' or 'N' depending on valid flag.
        --
        IF ( l_pcard_is_valid )
        THEN
            l_result_tbl(i) := 'Y';
        ELSE
            l_result_tbl(i) := 'N';
        END IF;

    END LOOP;

    -- Return -----------------------------------------------------------------

    return (l_result_tbl);

END get_pcard_valid_active_tbl;


/* is_site_pcard_enabled returns true if the vendor_id and vendor_site_id is
 * enabled for Pcard. If not return false.
*/
function is_site_pcard_enabled(x_vendor_id number,
			       x_vendor_site_id in number) return boolean is
x_valid number := 0;
begin
       	 begin
                 --<Shared Proc FPJ>
                 --Modified the query to select from po_vendor_sites_all
                 --instead of po_vendor_sites.
               	 select 1
               	 into x_valid
               	  from po_vendor_sites_all pvs
                	where pvs.VENDOR_ID = x_vendor_id
               	 	and pvs.vendor_site_id = x_vendor_site_id
               	 	and pvs.pcard_site_flag = 'Y';

               	 return TRUE; /* Site is pcard enabled*/
       	 exception
		when no_data_found then
               		return FALSE; /* Site is not pcard enabled*/
		when others then
			raise;
       	end;

end is_site_pcard_enabled;

-----------------------------------------------------------------------<HTMLAC>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_site_pcard_enabled_tbl
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Bulk version of is_site_pcard_enabled function. Takes in a nested table
--  of Vendor and Vendor Site IDs and returns a table 'Y' and 'N' indicating
--  whether each Vendor Site is P-Card enabled.
--Parameters:
--IN:
--p_vendor_id_tbl
--  PO_TBL_NUMBER consisting of Supplier identifier
--p_vendor_site_id_tbl
--  PO_TBL_NUMBER consisting of Supplier Site identifier
--Returns:
--  PO_TBL_VARCHAR1 consisting of 'Y' or 'N' indicating whether the
--  corresponding Supplier Site is P-Card enabled.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_site_pcard_enabled_tbl
(
    p_vendor_id_tbl       IN  PO_TBL_NUMBER
,   p_vendor_site_id_tbl  IN  PO_TBL_NUMBER
)
RETURN PO_TBL_VARCHAR1
IS
    l_result_tbl      PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

BEGIN

    l_result_tbl.extend(p_vendor_id_tbl.COUNT);

    FOR i IN p_vendor_id_tbl.FIRST..p_vendor_id_tbl.LAST
    LOOP
        IF ( is_site_pcard_enabled ( p_vendor_id_tbl(i)
                                   , p_vendor_site_id_tbl(i) )
           )
        THEN
            l_result_tbl(i) := 'Y';
        ELSE
            l_result_tbl(i) := 'N';
        END IF;
    END LOOP;

    return (l_result_tbl);

END get_site_pcard_enabled_tbl;


/* get_vendor_pcard_info returns pcard_id for the given vendor_id and
 * vendor_site_id for the supplier Pcard from ap_card_suppliers.
*/
function get_vendor_pcard_info(x_vendor_id in number,
			       x_vendor_site_id IN number) return number IS
x_pcard_id number;
begin
	begin
		select  card_id into x_pcard_id
		from ap_card_suppliers
		where vendor_id = x_vendor_id
		and vendor_site_id = x_vendor_site_id;
	exception
		when no_data_found then
			x_pcard_id := null;
		when others then
			raise;
	end ;
	return x_pcard_id;
end get_vendor_pcard_info;


/* get_valid_pcard_id returns pcard_id if the pcard_id is active,
 * not expired and the site is pcard enabled. If not, returns null.
*/
 function get_valid_pcard_id(x_pcard_id in number,
			     x_vendor_id in number,
			     x_vendor_site_id in number) return number is
x_valid boolean;
x_derived_pcard_id number;
begin
		if (x_pcard_id = -99999) then
			x_derived_pcard_id := get_vendor_pcard_info(
					x_vendor_id,x_vendor_site_id);
		else
			x_derived_pcard_id := x_pcard_id;
		end if;

                x_valid :=is_pcard_valid_and_active(x_derived_pcard_id);
		if (x_valid) then
		     x_valid :=is_site_pcard_enabled(x_vendor_id,x_vendor_site_id);
		end if;
		if (x_valid = FALSE) then
			x_derived_pcard_id := null;
		end if;
		return x_derived_pcard_id;
end get_valid_pcard_id;


END PO_PCARD_PKG;

/
