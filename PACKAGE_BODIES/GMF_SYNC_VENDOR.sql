--------------------------------------------------------
--  DDL for Package Body GMF_SYNC_VENDOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_SYNC_VENDOR" as
/* $Header: gmfvnsyb.pls 115.5 2002/12/04 17:04:34 umoogala ship $ */
    procedure gmf_sync_vendor(error_buf out nocopy varchar2,
                              retcode   out nocopy number,
                              p_co_code in varchar2)  is
   /* ---------------------
    -- Declare variables
    ---------------------- */
    v_last_update_date           date;
    v_total_vendors_synched       number:=0;
    v_org_id                     number;
    v_gl_log_trigger_cache       number;

    --Begin Bug 1677297 Mohit Kapoor
    --Added following variables
    v_vendor_id                 PO_VENDOR_SITES_ALL.VENDOR_ID%Type;
    v_vendor_site_code          PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%Type;
    v_segment1                  PO_VENDORS.SEGMENT1%Type;
    v_total_vendors_failed      number:=0;
    v_total_vendors             number:=0;
    --End Bug 1677297

    /*--------------------
    -- Declare cursor
    --------------------*/
    cursor c_gl_plcy_mst(p_co_code varchar2) is
    select decode(upper(f.multi_org_flag), 'Y', p.org_id, NULL)
    from gl_plcy_mst p,
         fnd_product_groups f
    where p.co_code=p_co_code;

    --Begin Bug 1677297 Mohit Kapoor
    -- Changed cursor definition added vendor_id, vendor_site_code
    cursor c_po_vendor_sites_all(p_co_code varchar2) is
    select i.last_update_date, i.vendor_id, i.vendor_site_code
    from po_vendor_sites_all i
    where nvl(i.org_id,-999) = nvl(v_org_id,-999)
    for update of last_update_date;
    --End Bug 1677297 Mohit Kapoor

    --Begin Bug 1677297 Mohit Kapoor Added cursor
	 cursor c_po_vendors(p_vendor_id Number) is
	 select v.segment1
	 from po_vendors v
	 where v.vendor_id = p_vendor_id;
    -- End Bug 1677297

    begin
    /*-----------------------------------------------------------------
    -- Cache the value of GL_LOG_TRIGGER_EXCEPTION to reset it in end.
    -----------------------------------------------------------------*/
    Gmf_sync_init.Glsynch_Initialize;
    v_gl_log_trigger_cache:=gmf_session_vars.gl_log_trigger_error;
    gmf_session_vars.gl_log_trigger_error:=1;

    --Begin Bug 1677297 Mohit Kapoor
    PRINT_LINE ('Starting concurrent program execution  ' ||to_char(sysdate, 'dd-mon-yyyy hh24:mi:ss'));
    PRINT_LINE ('COMPANY : '||p_co_code);
    PRINT_LINE ('');
    PRINT_LINE ( '-----------------------------------------------------------------');
    PRINT_LINE ('Vendor :-');
    --End Bug 1677297

    if (c_gl_plcy_mst%ISOPEN) then
      close c_gl_plcy_mst;
    end if;

    open  c_gl_plcy_mst(p_co_code);
    fetch c_gl_plcy_mst into v_org_id;
    close c_gl_plcy_mst;

    if (c_po_vendor_sites_all%ISOPEN) then
        close c_po_vendor_sites_all;
    end if;

    open  c_po_vendor_sites_all(v_org_id);
    loop
        --Begin Bug1677297 Mohit Kapoor
    	  Gmf_Session_Vars.FOUND_ERRORS := 'N';

    	  -- Modified Fetch statement 1677297
        fetch c_po_vendor_sites_all into v_last_update_date,v_vendor_id	,v_vendor_site_code ;
        exit when c_po_vendor_sites_all%NOTFOUND;

        GMF_Session_Vars.GL$VEND_DELIMITER := nvl(FND_PROFILE.VALUE('GL$VEND_DELIMITER'),'-');

        open c_po_vendors(v_vendor_id);
        fetch c_po_vendors into v_segment1;
        close c_po_vendors;

        PRINT (' '|| v_segment1 || GMF_Session_Vars.GL$VEND_DELIMITER || v_vendor_site_code );
        v_total_vendors:=v_total_vendors+1;
        --End Bug 1677297

        /*---------------------------------------------------
        -- This update will trigger vendor trigger to synch
        ---------------------------------------------------*/
        update po_vendor_sites_all
        set last_update_date=last_update_date
        where  current of c_po_vendor_sites_all;

        --Begin Bug1677297 Mohit Kapoor
        -- Added code
        if Gmf_Session_Vars.FOUND_ERRORS = 'N' then
           PRINT_LINE ('- Processed - Success ! '||to_char(sysdate, 'dd-mon-yyyy hh24:mi:ss'));
           v_total_vendors_synched := v_total_vendors_synched + 1;
        elsif Gmf_Session_Vars.FOUND_ERRORS = 'Y' then
           PRINT_LINE ('- Failed '||to_char(sysdate, 'dd-mon-yyyy hh24:mi:ss'));
	        v_total_vendors_failed := v_total_vendors_failed+1;
	     end if;
        --End Bug 1677297

    end loop;
    close c_po_vendor_sites_all;
    --Begin Bug1677297 Mohit Kapoor
    PRINT_LINE ( '-----------------------------------------------------------------');
    PRINT_LINE ('Records Failed = ' ||to_char(v_total_vendors_failed));
    PRINT_LINE ('Total Records Synched = ' || to_char(v_total_vendors_synched));
    PRINT_LINE ('Total Records  = ' || to_char(v_total_vendors));
    --End Bug 1677297

    /*--------------------------------------------------------
    -- Reset the Global pkg variable back to the cached value
    --------------------------------------------------------*/
    gmf_session_vars.gl_log_trigger_error:=v_gl_log_trigger_cache;
    retcode:=0;
    exception
        when others then
        fnd_message.set_name('GMF','GL_TRIGGER_ERROR');
        fnd_message.set_token('TRIGGER_NAME',substrb('GMF_SYNC_VENDOR-'||to_char(SQLCODE)||' '||SQLERRM,1,512));
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        retcode:=2;
    end;


/* REM  Wrapper for printing  */
/* Begin Bug1677297 Mohit Kapoor */
PROCEDURE PRINT_LINE
	(line_text	IN	VARCHAR2) IS
BEGIN
	FND_FILE.PUT_LINE ( FND_FILE.OUTPUT,line_text);
END;

PROCEDURE PRINT
	(line_text	IN	VARCHAR2) IS
BEGIN
	FND_FILE.PUT ( FND_FILE.OUTPUT,line_text);
END;
/* End Bug1677297 */
end gmf_sync_vendor;

/
