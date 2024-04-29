--------------------------------------------------------
--  DDL for Package Body PA_ASSET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSET_UTILS" as
--$Header: PAXAUTLB.pls 115.1 99/07/16 15:18:41 porting ship  $

--
--  FUNCTION
--              check_unique_asset_name
--  PURPOSE
--              This function returns 1 if asset name is not already
--              used for assets on this project and returns 0 if name is used.
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--
function check_unique_asset_name (x_asset_name  IN varchar2,
				  x_project_id IN number,
                                    x_rowid       IN varchar2 ) return number
is
    cursor c1 is
          select asset_name
	  from pa_project_assets
          where project_id = x_project_id
	  AND	asset_name = x_asset_name
          AND  (x_ROWID IS NULL OR x_ROWID <> pa_project_assets.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_asset_name is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           return(1);
        else
           return(0);
        end if;
        close c1;

exception
   when others then
        return(SQLCODE);

end check_unique_asset_name;

--
--  FUNCTION
--              check_valid_asset_number
--  PURPOSE
--              This function returns
--		   1 if asset number has not been used by PA.
--		   0 if asset number is already in use in PA
--			(further checking should be done to make
--			sure the asset is not in use in FA.  See
--			the FA_MASS_ADD_VALIDATE package.
--
--              If Oracle error occurs, Oracle error number is returned.
--
--
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--

function check_valid_asset_number (x_asset_number  IN varchar2,
                                    x_rowid       IN varchar2 ) return number
is

    cursor c1 is
          select asset_number
          from pa_project_assets
          where asset_number = x_asset_number
          AND  (x_ROWID IS NULL OR x_ROWID <> pa_project_assets.ROWID);

    c1_rec c1%rowtype;

begin
        if (x_asset_number is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
	--asset number used in PA?
        if c1%notfound then
	   return(1);
        else
           return(0);
        end if;
        close c1;

exception
   when others then
        return(SQLCODE);

end check_valid_asset_number;


--
--  FUNCTION
--              check_asset_references
--  PURPOSE
--              This function returns 1 if an asset can be deleted, and
--		returns 0 if the asset has references which prevent it
--		from being deleted.
--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   28-OCT-95      C. Conlin       Created
--
--

function check_asset_references (x_project_asset_id  IN number)
						 return number
is
    cursor c1 is
          select project_asset_id
          from pa_project_asset_lines
          where project_asset_id = x_project_asset_id;

    c1_rec c1%rowtype;

begin

        if (x_project_asset_id is null ) then
            return(null);
        end if;

        open c1;
        fetch c1 into c1_rec;
        if c1%notfound then
           return(1);
        else
           return(0);
        end if;
        close c1;

exception
   when others then
        return(SQLCODE);

end check_asset_references;

--  FUNCTION
--              check_fa_asset_num
--  PURPOSE
--              This function returns a 1 if the asset number being
--              checked is one of the valid FA asset numbers for the
--              given pa_asset_id.  This function returns a 0 if the
--              asset number is NOT a valid FA asset number for the
--              given pa_asset_id.
--
--              If Oracle error occurs, Oracle error number is returned.
--  HISTORY
--   29-JAN-96      C. Conlin       Created
--
--
function check_fa_asset_num(pa_asset_id IN NUMBER,
                        check_asset_number IN VARCHAR2) return number is

	cursor c1 (pa_asset_id NUMBER) is
        select distinct faa.asset_number
        from fa_additions faa,
                fa_asset_invoices fai,
                pa_project_asset_lines ppal
        where
                ppal.project_asset_id = pa_asset_id AND
                ppal.project_asset_line_id = fai.project_asset_line_id AND
                fai.asset_id = faa.asset_id;
        c1_rec  c1%ROWTYPE;

BEGIN
	FOR c1_rec in c1(pa_asset_id) LOOP
	  IF c1_rec.asset_number = check_asset_number THEN
	     RETURN(1);
	  END IF;
	END LOOP;
 	RETURN(0);
EXCEPTION
   when others then
        return(SQLCODE);
end check_fa_asset_num;


  FUNCTION fa_implementation_status RETURN VARCHAR2 is
        x_status        VARCHAR2(1);
        x_dummy         NUMBER;
  BEGIN
        SELECT  location_flex_structure
        INTO    x_dummy
        FROM    fa_system_controls;

        x_status := 'Y';
        return(x_status);
  EXCEPTION
    WHEN OTHERS THEN
        x_status := 'N';
        return(x_status);
  END fa_implementation_status;



end pa_asset_utils;

/
