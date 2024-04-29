--------------------------------------------------------
--  DDL for Package Body FND_INSTALLATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_INSTALLATION" AS
/* $Header: AFINSTLB.pls 120.2 2006/10/11 21:15:58 sdstratt ship $ */


  --
  -- Private Functions
  --
  FUNCTION private_get (appl_short_name     	in  varchar2,
			install_group_num	in  number,
			status			out nocopy varchar2,
			industry		out nocopy varchar2,
			product_version		out nocopy varchar2,
			oracle_schema		out nocopy varchar2,
			tablespace		out nocopy varchar2,
			index_tablespace	out nocopy varchar2,
			temporary_tablespace	out nocopy varchar2,
			sizing_factor		out nocopy number)
  			RETURN boolean;
  --
  -- Public Functions
  --

  FUNCTION get 	       (appl_id     IN  INTEGER,
                	dep_appl_id IN  INTEGER,
                	status      OUT NOCOPY VARCHAR2,
                	industry    OUT NOCOPY VARCHAR2)
  RETURN boolean IS
    l_appl_short_name		varchar2(50);

    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_product_version		varchar2(30);
    l_oracle_schema		varchar2(30);
    l_tablespace		varchar2(30);
    l_index_tablespace		varchar2(30);
    l_temporary_tablespace	varchar2(30);
    l_sizing_factor		number;
    l_return			boolean;
  BEGIN
    --
    --  The get() function no longer uses the appl_id argument
    --
    --  It calls private_get(), which gets the information for you
    --  based solely on the dep_appl_id and the current schema
    --
    --  get() may return different information with the same arguments
    --  if you connect to a different schema
    --
    status := 'N';
    industry := 'N';

    select application_short_name
    into l_appl_short_name
    from fnd_application
    where application_id = dep_appl_id;

    l_return := private_get(l_appl_short_name, null, l_status, l_industry,
			    l_product_version, l_oracle_schema, l_tablespace,
			    l_index_tablespace, l_temporary_tablespace,
			    l_sizing_factor);
    status := l_status;
    industry := l_industry;
    return(l_return);
  EXCEPTION
    -- This should only execute if an invalid dep_appl_id was passed
    when others then
    return(FALSE);
  END;

  FUNCTION get_app_info  (application_short_name	in  varchar2,
			status			out nocopy varchar2,
			industry		out nocopy varchar2,
			oracle_schema		out nocopy varchar2)
  RETURN boolean IS
    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_product_version		varchar2(30);
    l_oracle_schema		varchar2(30);
    l_tablespace		varchar2(30);
    l_index_tablespace		varchar2(30);
    l_temporary_tablespace	varchar2(30);
    l_sizing_factor		number;
    l_return			boolean;
  BEGIN
    --
    -- get_app_info() may return different information if you call it
    -- from a different schema
    -- See notes on get() above
    --
    l_return := private_get(application_short_name, null, l_status, l_industry,
			    l_product_version, l_oracle_schema, l_tablespace,
			    l_index_tablespace, l_temporary_tablespace,
			    l_sizing_factor);
    status := l_status;
    industry := l_industry;
    oracle_schema := l_oracle_schema;
    return(l_return);
  END;

  FUNCTION get_app_info_other  (application_short_name	in  varchar2,
			target_schema		in  varchar2,
			status			out nocopy varchar2,
			industry		out nocopy varchar2,
			oracle_schema		out nocopy varchar2)
  RETURN boolean IS
    l_install_group_num		number;
    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_product_version		varchar2(30);
    l_oracle_schema		varchar2(30);
    l_tablespace		varchar2(30);
    l_index_tablespace		varchar2(30);
    l_temporary_tablespace	varchar2(30);
    l_sizing_factor		number;
    l_return			boolean;
  BEGIN
    --
    -- get_app_info_other() will return consistent information every time
    -- you call it, because it ignores the current schema and uses
    -- the target_schema argument instead
    --
    status := 'N';
    industry := 'N';
    oracle_schema := null;

    -- Derive install_group_num from the parameter target_schema

    select min(install_group_num) into l_install_group_num
    from fnd_oracle_userid
    where oracle_username = target_schema;

    l_return := private_get(application_short_name, l_install_group_num,
			    l_status, l_industry,
			    l_product_version, l_oracle_schema, l_tablespace,
			    l_index_tablespace, l_temporary_tablespace,
			    l_sizing_factor);
    status := l_status;
    industry := l_industry;
    oracle_schema := l_oracle_schema;
    return(l_return);
  EXCEPTION
    -- This should only execute if the target schema was not registered in
    -- FND_ORACLE_USERID
    when others then
    return(FALSE);
  END;


  FUNCTION private_get (appl_short_name     	in  varchar2,
			install_group_num	in  number,
			status			out nocopy varchar2,
			industry		out nocopy varchar2,
			product_version		out nocopy varchar2,
			oracle_schema		out nocopy varchar2,
			tablespace		out nocopy varchar2,
			index_tablespace	out nocopy varchar2,
			temporary_tablespace	out nocopy varchar2,
			sizing_factor		out nocopy number)
  RETURN boolean IS

  BEGIN

/*
  The plan:

  Set default values: status=N, industry=N, others null

  First, try to get exactly one row from FND_PRODUCT_INSTALLATIONS
  for the product

  if found exactly one row,
   return TRUE with values from that row
  if no rows,
   return TRUE with default values (status=N, industry=N, others null)
  if more than one row,
   go on to next step

  At this point we know we have multiple rows for the product
   in FND_PRODUCT_INSTALLATIONS.

  NOTE: In R11 this condition should never
  occur and therefore the remaining logic should be removed then.
  Also note that in R11, the function get_app_info_other is obsolete
  because it is only necessary with multiple installs.  Also note that
  the argument installation_group_num to private_get is no longer
  needed as well.

  Next, if install_group_num is null then get the install_group_num from
   fnd_oracle_userid for the current user.

  Next, try to get exactly one row from FND_PRODUCT_INSTALLATIONS
   for the product, install_group_num pair

  if found exactly one row,
   return TRUE with values from that row
  if no rows,
   return TRUE with default values (status=N, industry=N, others null)
  if more than one row,
   return FALSE with default values (status=N, industry=N, others null)
   this case shouldn't happen

  Finally if an exception is raised return FALSE


  NOTES:
   Handles all cases in Single Oracle Accounts installation,
    since the select from FPI will always return either one row or no rows
   See note above as well as note below in the code.

  BUGS:
   If you do not pass install_group_num and the user account has a
   null install_group_num in fnd_oracle_userid and you have multiple installs
   of the product you will not be able to determine the information about
   the product.

   If you do not pass the install_group_num and the user account has a
   an install_group_num of 0 and you have multiple installs of the
   product and the product is a multiple install product (ie not
   install_group_num 0) you will not be able to determine the information
   about the product.  (eg. asking from applsys info about AP when
   multiple APs exist)

   Both of these problems go away in R11 when no more multiple installs.
*/

    -- dbms_output.put_line( 'entering private_get()' );

    status := 'N';
    industry := 'N';
    product_version := null;
    oracle_schema := null;
    tablespace := null;
    index_tablespace := null;
    temporary_tablespace := null;
    sizing_factor := null;

    /*------------------------------------------------------------+
     |  Get info regarding installs                               |
     +------------------------------------------------------------*/
    declare

     cursor FPI_CURSOR is
      select fpi.status,
	     fpi.industry,
	     fpi.product_version,
	     fou.oracle_username,
	     fpi.tablespace,
	     fpi.index_tablespace,
	     fpi.temporary_tablespace,
	     fpi.sizing_factor
      from FND_PRODUCT_INSTALLATIONS FPI,
	   FND_ORACLE_USERID FOU,
	   FND_APPLICATION FA
      where fpi.application_id = fa.application_id
      and   fpi.oracle_id = fou.oracle_id
      and   fa.application_short_name = private_get.appl_short_name;

     l_status			varchar2(1);
     l_industry			varchar2(1);
     l_product_version		varchar2(30);
     l_oracle_schema		varchar2(30);
     l_tablespace		varchar2(30);
     l_index_tablespace		varchar2(30);
     l_temporary_tablespace	varchar2(30);
     l_sizing_factor		number;

    begin

      open FPI_CURSOR;

      fetch FPI_CURSOR
      into l_status, l_industry, l_product_version, l_oracle_schema,
	   l_tablespace, l_index_tablespace, l_temporary_tablespace,
	   l_sizing_factor;

      if FPI_CURSOR%NOTFOUND then
        -- dbms_output.put( 'exiting private_get(): ' );
        -- dbms_output.put_line( 'product not in FPI' );
        close FPI_CURSOR;
        return(TRUE);
      end if;

      -- save results of fetch

      status := l_status;
      industry := l_industry;
      product_version := l_product_version;
      oracle_schema := l_oracle_schema;
      tablespace := l_tablespace;
      index_tablespace := l_index_tablespace;
      temporary_tablespace := l_temporary_tablespace;
      sizing_factor := l_sizing_factor;

      fetch FPI_CURSOR
      into l_status, l_industry, l_product_version, l_oracle_schema,
	   l_tablespace, l_index_tablespace, l_temporary_tablespace,
	   l_sizing_factor;

      if FPI_CURSOR%NOTFOUND then
        -- exactly one row.  return values from that row
        -- dbms_output.put_line( 'exiting private_get(): only one row in FPI');
        close FPI_CURSOR;
        return(TRUE);
      else
        -- more than one row.  go on to next block
	status := 'N';
	industry := 'N';
	product_version := null;
	oracle_schema := null;
	tablespace := null;
	index_tablespace := null;
	temporary_tablespace := null;
	sizing_factor := null;
        close FPI_CURSOR;
      end if;

    end;  -- look for single row in FPI

    /*------------------------------------------------------------+
     |  Get info for application and install_group_num            |
     |  NOTE:  All of the following code can be removed in R11    |
     |         as there will only be one install of the products. |
     +------------------------------------------------------------*/

    --
    -- If we got here, we must be looking for information for a MOA product
    --  that has been installed in more than one schema.
    --
    -- If we had been looking for a SOA product, we would have found it
    --  already, because SOA products (install_group_num = 0) never have
    --  more than one row in FND_PRODUCT_INSTALLATIONS.
    --
    -- If our reference schema is another MOA product account, or some other
    --  schema registered with install_group_num != 0, we should find
    --  exactly one row (or no rows) using the query below.  In this case,
    --  we exit with success.
    --
    -- If our reference schema is a SOA account (install_group_num = 0),
    --  we cannot accurately determine the information.
    -- In this case we exit with failure.
    --

    --
    -- Why can't we determine the information for a SOA schema?
    --
    -- Consider this example:
    --  o Multiple Sets of Books install, with two sets of books
    --  o AP fully-installed in the first set of books, shared in second
    --
    -- Which AP should GL point to?
    --
    -- Since GL handles both sets of books in one schema, neither AP is
    --  really correct.
    -- The AP in the first set of books only contains information for the
    --  first set of books, and the AP in the second set of books only
    --  contains information for the second set of books.
    --

    declare

     cursor FPI2_CURSOR (c_install_group_num number) is
      select fpi.status,
	     fpi.industry,
	     fpi.product_version,
	     fou.oracle_username,
	     fpi.tablespace,
	     fpi.index_tablespace,
	     fpi.temporary_tablespace,
	     fpi.sizing_factor
      from FND_PRODUCT_INSTALLATIONS FPI,
	   FND_ORACLE_USERID FOU,
	   FND_APPLICATION FA
      where fpi.application_id = fa.application_id
      and   fpi.oracle_id = fou.oracle_id
      and   fa.application_short_name = private_get.appl_short_name
      and   fpi.install_group_num = c_install_group_num;

     l_status			varchar2(1);
     l_industry			varchar2(1);
     l_product_version		varchar2(30);
     l_oracle_schema		varchar2(30);
     l_tablespace		varchar2(30);
     l_index_tablespace		varchar2(30);
     l_temporary_tablespace	varchar2(30);
     l_sizing_factor		number;
     l_install_group_num	number;

    begin

      -- If no install_group_num was passed, then derive it from
      -- the current user schema

      if private_get.install_group_num is null then

        select install_group_num
        into l_install_group_num
	from fnd_oracle_userid
        where oracle_username = user
        and install_group_num is not null;

      else

        l_install_group_num := private_get.install_group_num;

      end if;

      --
      -- If l_install_group_num is zero, return false
      -- See long comment above
      --

      if l_install_group_num = 0 then
        -- dbms_output.put('exiting private_get(): ');
        -- dbms_output.put_line('trying to get MOA info from SOA schema');
        return(FALSE);
      end if;

      open FPI2_CURSOR(l_install_group_num);

      fetch FPI2_CURSOR
      into l_status, l_industry, l_product_version, l_oracle_schema,
	   l_tablespace, l_index_tablespace, l_temporary_tablespace,
	   l_sizing_factor;

      if FPI2_CURSOR%NOTFOUND then
        -- dbms_output.put('exiting private_get(): ');
        -- dbms_output.put_line('app not in this install group?');
        close FPI2_CURSOR;
        return(TRUE);
      end if;

      -- save returned values

      status := l_status;
      industry := l_industry;
      product_version := l_product_version;
      oracle_schema := l_oracle_schema;
      tablespace := l_tablespace;
      index_tablespace := l_index_tablespace;
      temporary_tablespace := l_temporary_tablespace;
      sizing_factor := l_sizing_factor;

      fetch FPI2_CURSOR
      into l_status, l_industry, l_product_version, l_oracle_schema,
	   l_tablespace, l_index_tablespace, l_temporary_tablespace,
	   l_sizing_factor;

      if FPI2_CURSOR%NOTFOUND then
        -- exactly one row.  return values from that row
        -- dbms_output.put('exiting private_get(): MOA product - ');
        -- dbms_output.put_line('exactly one row found');
        close FPI2_CURSOR;
        return(TRUE);
      else
        -- more than one row. data corruption?
        -- dbms_output.put('exiting private_get: ');
        -- dbms_output.put_line('bad data in FND_ORACLE_USERID?');
	status := 'N';
	industry := 'N';
	product_version := null;
	oracle_schema := null;
	tablespace := null;
	index_tablespace := null;
	temporary_tablespace := null;
	sizing_factor := null;
        return(FALSE);
      end if;

    end;  -- multiple FPI rows

    -- dbms_output.put_line( 'exiting private_get(): should not reach here' );
    return(FALSE);

  EXCEPTION
    when others then
      -- dbms_output.put_line( 'exiting private_get() with following error:' );
      -- dbms_output.put_line( sqlerrm );
      return(FALSE);

  END private_get;

END FND_INSTALLATION;

/

  GRANT EXECUTE ON "APPS"."FND_INSTALLATION" TO "AMV";
