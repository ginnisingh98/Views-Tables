--------------------------------------------------------
--  DDL for Package Body JG_GLOBE_FLEX_VAL_SHARED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_GLOBE_FLEX_VAL_SHARED" AS
/* $Header: jggdfvsb.pls 120.1 2005/07/01 19:55:20 sachandr ship $ */

  --
  -- PUBLIC PROCEDURE
  --
  ---------------------------------------------------------------------------
  --  INSERT_REJECTIONS():
  --     AP Invoice Gateway Import Process uses this procedure to reject
  --     invalid data and insert them to AP_INTERFACE_REJECTIONS table.
  --     The table stores both header and line level invoice information.
  --     The column PARENT_TABLE indicates the table from which the invoice
  --     fetched is being rejected - AP_INVOICES_INTERFACE or
  --     AP_INVOICE_LINES_INTERFACE. If the source of PARENT_TABLE is
  --     AP_INVOICES_INTERFACE then the column PARENT_ID would have the
  --     invoice_id else if the source of PARENT_TABLE is
  --     AP_INVOICE_LINES_INTERFACE, then PARENT_ID would have
  --     invoice_line_id.
  ---------------------------------------------------------------------------
  PROCEDURE Insert_rejections(
	p_parent_table			IN	VARCHAR2,
	p_parent_id			IN	NUMBER,
	p_reject_code			IN	VARCHAR2,
	p_last_updated_by		IN	NUMBER,
	p_last_update_login		IN	NUMBER,
	p_calling_sequence   		IN    	VARCHAR2) IS

        l_debug_loc                     VARCHAR2(30) := 'Insert_Rejections';
        l_curr_calling_sequence  	VARCHAR2(2000);
        l_debug_info                    VARCHAR2(100);
  BEGIN
    -------------------------- DEBUG INFORMATION ------------------------------
    l_curr_calling_sequence := 'jg_globe_flex_val.'||l_debug_loc||'<-'||p_calling_sequence;
    l_debug_info := 'Insert rejection information to ap_interface_rejections';
    ---------------------------------------------------------------------------
    --
    -- Insert into AP_INTERFACE_REJECTIONS
    --
    INSERT INTO ap_interface_rejections(
    	         parent_table,
	         parent_id,
	         reject_lookup_code,
	         last_updated_by,
	         last_update_date,
	         last_update_login,
	         created_by,
	         creation_date)
         VALUES (p_parent_table,
	         p_parent_id,
	         p_reject_code,
	         p_last_updated_by,
	         sysdate,
	         p_last_update_login,
	         p_last_updated_by,
	         sysdate);

  EXCEPTION
  WHEN OTHERS then
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            'Parent Table = '||p_parent_table
                        ||', Parent Id = '||to_char(p_parent_id)
                        ||', Reject Code = '||p_reject_code
                        ||', Last Updated By = '||to_char(p_last_updated_by)
                        ||', Last Update Date = '||to_char(p_last_update_login));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_rejections;

  ---------------------------------------------------------------------------
  --  UPDATE_RA_CUSTOMERS_INTERFACE():
  --
  --   Update Interface_status column  with error or warning code
  --   in RA_CUSTOMERS_INTERFACE View.
  ---------------------------------------------------------------------------
  PROCEDURE update_ra_customers_interface(
          p_code               IN      VARCHAR2,
          p_row_id             IN      VARCHAR2,
          p_current_status     IN      VARCHAR2) IS

  BEGIN
    IF p_current_status = 'E' THEN
      UPDATE ra_customers_interface
      SET interface_status = interface_status||p_code
      WHERE ROWID = p_row_id;
    ELSIF p_current_status = 'W' THEN
      UPDATE ra_customers_interface
      SET warning_text = warning_text||p_code
      WHERE rowid = p_row_id;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_standard.debug('No data found in RA_CUSTOMERS_INTERFACE View');
  WHEN OTHERS THEN
    arp_standard.debug('Exception in JG_GLOBE_FLEX_VAL1.UPDATE_RA_CUSTOMERS_INTERFACE()');
    arp_standard.debug(SQLERRM);
  END update_ra_customers_interface;

  ---------------------------------------------------------------------------
  -- UPDATE_INTERFACE_STATUS():
  --
  -- PURPOSE
  -- Update Interface Status with a Given Message Code.
  -- Use this procedure for new validation in 11.5.1 or later
  -- instead of update_ra_customers_interface.
  --
  -- PARAMETERS
  -- ** Valid Parameter Values for p_table_name **
  -- 1. ra_customers_interface
  -- 2. ra_customer_profiles_interface
  -- 3. ra_contact_phones_interface
  -- 4. ra_customer_banks_interface
  -- 5. ra_cust_pay_method_interface
  ---------------------------------------------------------------------------
  PROCEDURE update_interface_status(
         p_rowid                       IN VARCHAR2,
         p_table_name                  IN VARCHAR2,
         p_code                        IN VARCHAR2,
         p_current_status              IN VARCHAR2) IS

    TYPE TableName IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;

    l_table_tab       TableName;
    l_rowid           ROWID            DEFAULT p_rowid;
    l_table_name      VARCHAR2(30)     DEFAULT p_table_name;
    l_code            VARCHAR2(200)    DEFAULT p_code;
    l_current_status  VARCHAR2(1)      DEFAULT p_current_status;

    l_sql_stmt        VARCHAR2(200);
    l_sql_stmt_upd    VARCHAR2(200);
    l_sql_stmt_set    VARCHAR2(200);
    l_sql_stmt_where  VARCHAR2(200);

    Invalid_Table     EXCEPTION;

  BEGIN
    -- ** Index **
    -- 1. Validate Table Name
    -- 2. Build Common Update Statement
    -- 3. Build Update Statement for Errors
    -- 4. Build Update Statement for Warnings
    -- 5. Bulid Final Update Statement
    -- 6. Execute Update Statement
    -- 7. Raise Exception When No Row is Updated
    --

    --
    -- Validate Table Name
    --
    -- Add "l_table_tab(i) := <Table Name>;" for new interface tables.
    --
    l_table_tab(1) := 'RA_CUSTOMERS_INTERFACE';
    l_table_tab(2) := 'RA_CUSTOMER_PROFILES_INTERFACE';
    l_table_tab(3) := 'RA_CONTACT_PHONES_INTERFACE';
    l_table_tab(4) := 'RA_CUSTOMER_BANKS_INTERFACE';
    l_table_tab(5) := 'RA_CUST_PAY_METHOD_INTERFACE';

    FOR i IN 1..l_table_tab.COUNT LOOP
      --
      -- If a table name is valid, exit the loop.
      --
      IF l_table_tab(i) = UPPER(l_table_name) THEN
        EXIT;
      END IF;
      --
      -- If a table name is invalid, raise an exception.
      --
      IF i = l_table_tab.COUNT THEN
        RAISE Invalid_Table;
      END IF;
    END LOOP;
    --
    -- Update Interface Tables When Current Status is 'E' or 'W'.
    --
    IF l_current_status IN ('E','W') THEN
      --
      -- Build Common Update Statement
      --
      l_sql_stmt_upd   := 'UPDATE ' || l_table_name;
      l_sql_stmt_where := ' WHERE rowid = :v_rowid';

      --
      -- Build Update Statement for Errors
      --
      IF l_current_status = 'E' THEN
        l_sql_stmt_set := ' SET interface_status = interface_status || :v_code';

      --
      -- Build Update Statement for Warnings
      --
      ELSIF l_current_status = 'W' THEN
        IF UPPER(l_table_name) = 'RA_CUSTOMERS_INTERFACE' THEN
          l_sql_stmt_set := ' SET warning_text = warning_text || :v_code';
        ELSE
          RAISE Invalid_Table;
        END IF;
      END IF;

      --
      -- Bulid Final Update Statement
      --
      l_sql_stmt := l_sql_stmt_upd || l_sql_stmt_set || l_sql_stmt_where;

      --
      -- Execute Update Statement
      --
      EXECUTE IMMEDIATE l_sql_stmt USING l_code, l_rowid;

      --
      -- Raise Exception When No Row is Updated.
      --
      IF SQL%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;
  EXCEPTION
  WHEN Invalid_Table THEN
    arp_standard.debug(SQLERRM);
    arp_standard.debug('Invalid Table Name: ' || l_table_name);
    RAISE;
  WHEN OTHERS THEN
    arp_standard.debug(SQLERRM);
    arp_standard.debug(l_sql_stmt);
    RAISE;
  END;

  ---------------------------------------------------------------------------
  --  CHECK_FORMAT():
  --
  --   Check format of each descriptive flexfield segment
  ---------------------------------------------------------------------------
  FUNCTION check_format(
                       p_value          IN VARCHAR2,
                       p_format_type    IN VARCHAR2,
                       p_maximum_size   IN NUMBER,
                       p_precision      IN NUMBER,
                       p_alphanumeric   IN VARCHAR2,
                       p_uppercase_only IN VARCHAR2,
                       p_right_justify  IN VARCHAR2,
                       p_min_value      IN VARCHAR2,
                       p_max_value      IN VARCHAR2 )
  RETURN BOOLEAN IS

    c_num          NUMBER;
    c_date         DATE;

  FUNCTION check_maximum_size( v IN VARCHAR2, s in NUMBER )
  RETURN BOOLEAN IS
  BEGIN
    if( lengthb( v ) > s ) then
      return( FALSE );
    else
      return( TRUE );
    end if;
  END check_maximum_size;

  FUNCTION check_maximum_size_just( v IN VARCHAR2, s in NUMBER )
  RETURN BOOLEAN IS
  BEGIN
    if( lengthb( v ) <> s ) and ( v IS NOT NULL) then
      return( FALSE );
    else
      return( TRUE );
    end if;
  END check_maximum_size_just;

  FUNCTION check_date9( v IN VARCHAR2, d OUT NOCOPY DATE )
  RETURN BOOLEAN IS
  BEGIN
    d :=  fnd_date.chardate_to_date( v );
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      d := NULL;
      return(FALSE);
  END check_date9;

  FUNCTION check_date11( v IN VARCHAR2, d OUT NOCOPY DATE )
  RETURN BOOLEAN IS
  BEGIN
    d :=  fnd_date.chardate_to_date( v );
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      d := NULL;
      return(FALSE);
  END check_date11;

  FUNCTION check_number( v IN VARCHAR2, n OUT NOCOPY NUMBER )
  RETURN BOOLEAN IS
  BEGIN
    n := to_number( v );
    return(TRUE);
  EXCEPTION
    WHEN OTHERS then
      n := NULL;
      return(FALSE);
  END check_number;

  FUNCTION check_uppercase( v IN VARCHAR2 )
  RETURN BOOLEAN IS
    dummy VARCHAR2(150);
  BEGIN
    dummy := upper( v );
    if( dummy <> v ) then
      return( FALSE );
    else
      return( TRUE );
    end if;
  END check_uppercase;

  BEGIN

  if( p_format_type = 'C' )then

    if ( NOT check_maximum_size( p_value, p_maximum_size ) ) then
      return( FALSE );
    end if;

    if( p_alphanumeric = 'N' ) then
      if( NOT check_number( p_value, c_num ) ) then
        return( FALSE );
      end if;
    end if;

    if( p_uppercase_only = 'Y' ) then
      if( NOT check_uppercase( p_value ) ) then
        return( FALSE );
      end if;
    end if;

    if( p_right_justify = 'Y' ) then
      if( NOT check_maximum_size_just( p_value, p_maximum_size ) ) then
        return( FALSE );
      end if;
    end if;

  elsif( p_format_type = 'D' )then

    if ( NOT check_maximum_size_just( p_value, p_maximum_size ) ) then
      return( FALSE );
    end if;

    if( NOT check_uppercase( p_value ) ) then
      return( FALSE );
    end if;

    if ( p_maximum_size = 9 ) then

      if( NOT check_date9( p_value, c_date ) ) then
        return( FALSE );
      end if;

    elsif ( p_maximum_size = 11 ) then

      if( NOT check_date11( p_value, c_date ) ) then
        return( FALSE );
      end if;

    end if;

  elsif( p_format_type = 'N' )then

    if ( NOT check_maximum_size( p_value, p_maximum_size ) ) then
      return( FALSE );
    end if;

    if( NOT check_number( p_value, c_num ) ) then
      return( FALSE );
    end if;

  end if;

    return( TRUE );

  END check_format;

END jg_globe_flex_val_shared;

/
