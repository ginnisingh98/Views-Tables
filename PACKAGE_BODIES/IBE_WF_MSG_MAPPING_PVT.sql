--------------------------------------------------------
--  DDL for Package Body IBE_WF_MSG_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_WF_MSG_MAPPING_PVT" as
/* $Header: IBEVWMMB.pls 120.0.12010000.2 2009/07/03 05:03:06 scnagara ship $ */

--debug_mode boolean DEFAULT TRUE;
debug_mode boolean DEFAULT FALSE;
/** Globals to hold Logging attributs **/
g_fd utl_file.file_type;         -- Log file descriptor
 procedure debug(p_msg IN VARCHAR2) IS
   l_debug VARCHAR2(1);

 begin
         l_debug := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   if( debug_mode = TRUE) then
     --dbms_output.put_line(p_msg);
     IF (l_debug = 'Y') THEN
        IBE_UTIL.debug(p_msg);
     END IF;
   end if;
end;

procedure TraceLog(err_msg IN VARCHAR2, module IN VARCHAR2) is
   l_dbg_lvl            NUMBER := 0;
   l_dbgdir             VARCHAR2(128);
   l_dbgfile            VARCHAR2(32) := 'IBEVRUTB.log';
   l_err_msg            VARCHAR2(256);
   l_ndx                NUMBER;
   l_prevndx            NUMBER;
   l_strlen             NUMBER;
begin
           select value
           into l_dbgdir
           from v$PARAMETER
           where name = 'utl_file_dir';

           if( instr(l_dbgdir, ',') > 0 ) then
               l_dbgdir := substr(l_dbgdir, 1, instr(l_dbgdir, ',')-1);
           end if;

           -- open the log file
           g_fd := utl_file.fopen(l_dbgdir, l_dbgfile, 'a');
           utl_file.put_line(g_fd, '');
           select to_char(sysdate, 'DD-MON-YY:HH.MI.SS') into l_err_msg from dual;
           utl_file.put_line(g_fd, 'IBEVRUTB: ******** New Session. : '||l_err_msg||' **********');
        utl_file.put_line(g_fd, module||': ' || err_msg);
        utl_file.fflush(g_fd);
EXCEPTION
   when utl_file.INVALID_PATH then
        --dbms_output.put_line('*********Error: Invalid Path ');
        null;
   when others then
        l_err_msg := substr(sqlerrm, 1, 240);
        --dbms_output.put_line('***** SQL Error: ' || l_err_msg);
        null;
end TraceLog;

procedure find_msite(
	p_msite_id	 IN NUMBER,
	p_notif_setup_id IN NUMBER,
	x_msite_tbl	OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_msite_tbl WFMSG_TBL_TYPE;
    cursor msite_csr(p_notif_setup_id IN NUMBER, p_msite_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and msite_id = p_msite_id
       and enabled_flag = 'Y';  -- bug 7720550, scnagara

    cursor msite_null_csr(p_notif_setup_id IN NUMBER, p_msite_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and msite_id is null
       and enabled_flag = 'Y';  -- bug 7720550, scnagara

    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    if( p_msite_id is null ) then
        open msite_null_csr(p_notif_setup_id, p_msite_id);
        LOOP
	    fetch msite_null_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_Rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_type_flag;
	    EXIT when msite_null_csr%NOTFOUND;
            l_msite_tbl(l_idx) := l_wfmsg_rec;
            l_idx := l_idx + 1;
        END LOOP;
	close msite_null_csr;
    else
        open msite_csr(p_notif_setup_id, p_msite_id);
        LOOP
	    fetch msite_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_Rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_type_flag;
	    EXIT when msite_csr%NOTFOUND;
            l_msite_tbl(l_idx) := l_wfmsg_rec;
            l_idx := l_idx + 1;
        END LOOP;
        close msite_csr;
    end if;
    x_msite_tbl := l_msite_tbl;
END;

procedure find_all_msite(
        p_notif_setup_id	IN NUMBER,
	x_msite_tbl		OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_msite_tbl WFMSG_TBL_TYPE;
    cursor msite_csr(p_notif_setup_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and all_msite_flag = 'Y'
       and enabled_flag = 'Y' ; -- bug 7720550, scnagara
    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    open msite_csr(p_notif_setup_id);
    LOOP
	fetch msite_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_Type_flag;
	EXIT when msite_csr%NOTFOUND;
        l_msite_tbl(l_idx) := l_wfmsg_rec;
        l_idx := l_idx + 1;
    END LOOP;
    close msite_csr;
    x_msite_tbl := l_msite_tbl;
end;

procedure find_org(
        p_in_msg_tbl		IN WFMSG_TBL_TYPE,
	p_org_id		IN NUMBER,
	x_out_msg_tbl		OUT NOCOPY WFMSG_TBL_TYPE) IS
   l_out_msg_tbl WFMSG_TBL_TYPE;
   l_out_idx     NUMBER;
BEGIN
debug('find_org ' || p_org_id);
   l_out_idx := 1;
   for i in 1..p_in_msg_tbl.COUNT LOOP
	debug('p_in_msg_tbl(i).org_id = ' || p_in_msg_tbl(i).org_id);
       if( p_org_id is null ) then
	   if( p_in_msg_tbl(i).org_id is null ) then
	       l_out_msg_tbl(l_out_idx) := p_in_msg_tbl(i);
	       l_out_idx := l_out_idx + 1;
	   end if;
       else
           if( p_in_msg_tbl(i).org_id = p_org_id ) THEN
	       l_out_msg_tbl(l_out_idx) := p_in_msg_tbl(i);
               l_out_idx := l_out_idx +1;
	   end if;
       end if;
   end loop;
   debug('l_out_idx = ' || l_out_idx);
   x_out_msg_tbl := l_out_msg_tbl;
END;

procedure find_all_org(
	p_in_msg_tbl		IN WFMSG_TBL_TYPE,
	x_out_msg_tbl		OUT NOCOPY WFMSG_TBL_TYPE) IS
   l_out_msg_tbl WFMSG_TBL_TYPE;
   l_out_idx NUMBER;
BEGIN
   l_out_idx := 1;
   for i in 1..p_in_msg_tbl.COUNT LOOP
      if( p_in_msg_tbl(i).all_org_flag = 'Y') THEN
	  l_out_msg_tbl(l_out_idx) := p_in_msg_tbl(i);
          l_out_idx := l_out_idx + 1;
      end if;
   end lOOP;
   x_out_msg_tbl := l_out_msg_tbl;
END;

procedure find_user_type(
     p_in_msg_tbl 	IN WFMSG_TBL_TYPE,
     p_user_type 	IN VARCHAR2,
     x_out_msg_tbl	OUT NOCOPY WFMSG_TBL_TYPE) IS
  l_out_msg_tbl WFMSG_TBL_TYPE;
  l_out_idx NUMBER := 1;
BEGIN
   --dbms_output.put_line('p_user_type is ' || p_user_type);
   for i in 1..p_in_msg_tbl.COUNT LOOP
     -- dbms_output.put_line('p_in_msg_tbl(i).user_type is ' || p_in_msg_tbl(i).user_type);
      if( upper(p_in_msg_tbl(i).user_type) = upper(p_user_type) ) THEN
	--  dbms_output.put_line('found match');
	  l_out_msg_tbl(l_out_idx) := p_in_msg_tbl(i);
          l_out_idx := l_out_idx + 1;
      end if;
   end loop;
  --dbms_output.put_line('l_out_idx is ' ||l_out_msg_tbl.COUNT);
  x_out_msg_tbl := l_out_msg_tbl;
END;

procedure find_all_user_type(
     p_in_msg_tbl 	IN WFMSG_TBL_TYPE,
     x_out_msg_tbl	OUT NOCOPY WFMSG_TBL_TYPE) IS
  l_out_msg_tbl WFMSG_TBL_TYPE;
  l_out_idx NUMBER := 1;
BEGIN
   for i in 1..p_in_msg_tbl.COUNT LOOP
      if( p_in_msg_tbl(i).all_user_type_flag = 'Y' ) THEN
	  l_out_msg_tbl(l_out_idx) := p_in_msg_tbl(i);
          l_out_idx := l_out_idx + 1;
      end if;
   end loop;
   x_out_msg_tbl := l_out_msg_tbl;
END;

procedure get_default_msg(
	x_wf_msg_name	OUT NOCOPY VARCHAR2,
	x_enabled_flag  OUT NOCOPY VARCHAR2,
	p_notif_Setup_id IN NUMBER) IS
    cursor default_msg(p_notif_setup_id IN NUMBER) is
	select message_name, enabled_flag
	from IBE_WF_NOTIF_MSG_MAPS
	WHERE notif_setup_id = p_notif_setup_id
	and default_msg_map_flag = 'Y';
    l_wf_msg_name VARCHAR2(30);
    l_enabled_flag VARCHAR2(1);
BEGIN
    open default_msg(p_notif_setup_id);
    LOOP
       fetch default_msg into l_wf_msg_name, l_enabled_flag;
       exit when default_msg%NOTFOUND;
    end LOOP;
    close default_msg;
    x_wf_msg_name := l_wf_msg_name;
    x_enabled_flag := l_enabled_flag;
END;

procedure Get_MSGNAME_BY_ORGUSERTYPE(
	x_wf_msg_name	OUT NOCOPY VARCHAR2,
        x_enabled_flag  OUT NOCOPY VARCHAR2,
	p_notif_setup_id IN NUMBER,
	p_org_id	 IN NUMBER,
	p_user_type	 IN VARCHAR2,
	p_in_msg_tbl	 IN WFMSG_TBL_TYPE) IS
   l_org_tbl WFMSG_TBL_TYPE;
   l_user_type_tbl WFMSG_TBL_TYPE;
   l_wf_msg_name VARCHAR2(30);
   l_enabled_flag VARCHAR2(1);
   l_wfmsg_tbl WFMSG_TBL_TYPE := p_in_msg_tbl;
BEGIN
debug('get_msgname_by_orgusertype 1');
    find_org(l_wfmsg_tbl, p_org_id, l_org_tbl);
    if( l_org_tbl.COUNT = 0 ) then
debug('get_msgname_by_orgusertype 2');
        find_all_org(l_wfmsg_tbl, l_org_tbl);
        if( l_org_tbl.COUNT = 0 ) THEN
debug('get_msgname_by_orgusertype 3');
            get_default_msg(l_wf_msg_name, l_enabled_flag, p_notif_setup_id);
        else
debug('get_msgname_by_orgusertype 4');
            find_user_type(l_org_tbl, p_user_type, l_user_type_tbl);
            if( l_user_type_Tbl.COUNT = 0 ) then
debug('get_msgname_by_orgusertype 5');
                find_all_user_type(l_org_tbl, l_user_type_tbl);
                if( l_user_type_tbl.COUNT = 0 ) then
debug('get_msgname_by_orgusertype 6');
                    get_default_msg(l_wf_msg_name, l_enabled_flag, p_notif_setup_id);
                else
debug('get_msgname_by_orgusertype 7');
                    l_wf_msg_name := l_user_type_tbl(1).message_name;
                    l_enabled_flag := l_user_type_tbl(1).enabled_flag;
                end if;
            else
debug('get_msgname_by_orgusertype 8');
                l_wf_msg_name := l_user_type_tbl(1).message_name;
                l_enabled_flag := l_user_type_tbl(1).enabled_flag;
            end if;
        end if;
    else
debug('get_msgname_by_orgusertype 9');
        find_user_type(l_org_tbl, p_user_type, l_user_type_tbl);
        if( l_user_type_Tbl.COUNT = 0 ) then
debug('get_msgname_by_orgusertype 10');
            find_all_user_type(l_org_tbl, l_user_type_tbl);
            if( l_user_type_tbl.COUNT = 0 ) then
debug('get_msgname_by_orgusertype 11');
                get_default_msg(l_wf_msg_name, l_enabled_flag, p_notif_setup_id);
            else
debug('get_msgname_by_orgusertype 12');
                l_wf_msg_name := l_user_type_tbl(1).message_name;
                l_enabled_flag := l_user_type_tbl(1).enabled_flag;

            end if;
        else
debug('get_msgname_by_orgusertype 13');
            l_wf_msg_name := l_user_type_tbl(1).message_name;
            l_enabled_flag := l_user_type_tbl(1).enabled_flag;
        end if;
    end if;

   x_wf_msg_name := l_wf_msg_name;
   x_enabled_flag := l_enabled_flag;
END;

Procedure get_msg_name_by_org(
	x_wf_msg_name 	OUT NOCOPY VARCHAR2,
        x_enabled_flag  OUT NOCOPY VARCHAR2,
	p_notif_setup_id IN NUMBER,
	p_org_id	 IN NUMBER,
	p_in_msg_tbl	IN WFMSG_TBL_TYPE) IS
   l_wf_msg_name VARCHAR2(30);
   l_enabled_flag VARCHAR2(1);
   l_org_tbl WFMSG_TBL_TYPE;
   l_wfmsg_tbl WFMSG_TBL_TYPE := p_in_msg_tbl;
BEGIN
debug('get_msg_name_by_org 1');
   find_org(l_wfmsg_tbl, p_org_id, l_org_tbl);
   if( l_org_tbl.COUNT = 0 ) then
debug('get_msg_name_by_org 2');
       find_all_org(l_wfmsg_tbl, l_org_tbl);
       if( l_org_tbl.COUNT = 0 ) THEN
debug('get_msg_name_by_org 3');
           get_default_msg(l_wf_msg_name, l_enabled_flag, p_notif_setup_id);
       else
debug('get_msg_name_by_org 4');
	   l_wf_msg_name := l_org_tbl(1).message_name;
           l_enabled_flag := l_org_tbl(1).enabled_flag;
       end if;
   else
debug('get_msg_name_by_org 5');
       l_wf_msg_name := l_org_tbl(1).message_name;
       l_enabled_flag := l_org_tbl(1).enabled_flag;
   end if;
   x_wf_msg_name := l_wf_msg_name;
   x_enabled_flag := l_enabled_flag;
END;

procedure get_msg_name_by_usertype(
      x_wf_msg_name	OUT NOCOPY VARCHAR2,
      x_enabled_flag    OUT NOCOPY VARCHAR2,
      p_notif_Setup_id  IN  NUMBER,
      p_user_type	IN  VARCHAR2,
      p_in_msg_tbl      IN WFMSG_TBL_TYPE) IS
   l_wf_msg_name VARCHAR2(30);
   l_enabled_flag VARCHAR2(1);
   l_user_type_tbl WFMSG_TBL_TYPE;
   l_wfmsg_tbl WFMSG_TBL_TYPE := p_in_msg_tbl;
BEGIN
   debug('get_msg_name_by_usertype 1');
   find_user_type(l_wfmsg_tbl, p_user_type, l_user_type_tbl);
   if( l_user_type_tbl.COUNT = 0 ) THEN
   debug('get_msg_name_by_usertype 2');
       find_all_user_type(l_wfmsg_tbl, l_user_type_tbl);
       if( l_user_type_tbl.COUNT = 0 ) THEN
   debug('get_msg_name_by_usertype 3');
	   get_default_msg(l_wf_msg_name, l_enabled_flag, p_notif_setup_id);
       else
   debug('get_msg_name_by_usertype 4');
	   l_wf_msg_name := l_user_type_tbl(1).message_name;
           l_enabled_flag := l_user_type_tbl(1).enabled_flag;
       end if;
   else
   debug('get_msg_name_by_usertype 5');
      l_wf_msg_name := l_user_type_tbl(1).message_name;
      l_enabled_flag := l_user_type_tbl(1).enabled_flag;
   end if;
   x_wf_msg_name := l_wf_msg_name;
   x_enabled_flag := l_enabled_flag;
END;

Procedure find_org_no_msite(
	p_org_id	 IN NUMBER,
	p_notif_setup_id IN NUMBER,
	x_org_tbl	OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_org_tbl WFMSG_TBL_TYPE;
    cursor org_null_csr(p_notif_setup_id IN NUMBER, p_org_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and org_id is null;
    cursor org_csr(p_notif_setup_id IN NUMBER, p_org_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and org_id = p_org_id;
    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    if( p_org_id is null ) then
        open org_null_csr(p_notif_setup_id, p_org_id);
        LOOP
	    fetch org_null_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_Rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_type_flag;
	    EXIT when org_null_csr%NOTFOUND;
            l_org_tbl(l_idx) := l_wfmsg_rec;
            l_idx := l_idx + 1;
        END LOOP;
	close org_null_csr;
    else
        open org_csr(p_notif_setup_id, p_org_id);
        LOOP
	    fetch org_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_Rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_type_flag;
	    EXIT when org_csr%NOTFOUND;
            l_org_tbl(l_idx) := l_wfmsg_rec;
            l_idx := l_idx + 1;
        END LOOP;
        close org_csr;
    end if;
    x_org_tbl := l_org_tbl;
END;

procedure find_all_org_no_msite(
        p_notif_setup_id	IN NUMBER,
	x_org_tbl		OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_org_tbl WFMSG_TBL_TYPE;
    cursor org_csr(p_notif_setup_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and all_org_flag = 'Y';
    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    open org_csr(p_notif_setup_id);
    LOOP
	fetch org_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_Type_flag;
	EXIT when org_csr%NOTFOUND;
        l_org_tbl(l_idx) := l_wfmsg_rec;
        l_idx := l_idx + 1;
    END LOOP;
     close org_csr;
    x_org_tbl := l_org_tbl;
END;

Procedure find_user_type_only(
	p_user_type	 IN VARCHAR2,
	p_notif_setup_id IN NUMBER,
	x_user_type_tbl	OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_user_type_tbl WFMSG_TBL_TYPE;
    cursor user_type_csr(p_notif_setup_id IN NUMBER, p_user_type IN VARCHAR2) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and user_type = p_user_type;
    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    open user_type_csr(p_notif_setup_id, p_user_type);
    LOOP
	fetch user_type_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_Rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_type_flag;
	EXIT when user_type_csr%NOTFOUND;
        l_user_type_tbl(l_idx) := l_wfmsg_rec;
        l_idx := l_idx + 1;
    END LOOP;
    close user_type_csr;
    x_user_type_tbl := l_user_type_tbl;
END;

procedure find_all_user_type_only(
        p_notif_setup_id	IN NUMBER,
	x_user_type_tbl		OUT NOCOPY WFMSG_TBL_TYPE) IS
    l_user_type_tbl WFMSG_TBL_TYPE;
    cursor user_type_csr(p_notif_setup_id IN NUMBER) IS
       select notif_msg_map_id, notif_setup_id, message_name, enabled_flag, msite_id, org_id, user_type,
		all_msite_flag, all_org_flag, all_user_Type_flag
       from ibe_wf_notif_msg_maps
       where notif_setup_id = p_notif_setup_id
       and all_user_type_flag = 'Y';
    l_idx NUMBER := 1;
    l_wfmsg_rec WFMSG_REC_TYPE;
BEGIN
    open user_type_csr(p_notif_setup_id);
    LOOP
	fetch user_type_csr into l_wfmsg_rec.notif_msg_map_id, l_wfmsg_rec.notif_setup_id, l_wfmsg_rec.message_name,
	      l_wfmsg_rec.enabled_flag, l_wfmsg_rec.msite_id, l_wfmsg_rec.org_id, l_wfmsg_rec.user_type,
	      l_wfmsg_rec.all_msite_flag, l_wfmsg_rec.all_org_flag, l_wfmsg_rec.all_user_Type_flag;
	EXIT when user_type_csr%NOTFOUND;
        l_user_type_tbl(l_idx) := l_wfmsg_rec;
        l_idx := l_idx + 1;
    END LOOP;
    close user_type_csr;
    x_user_type_tbl := l_user_type_tbl;
END;

procedure Retrieve_Msg_Mapping
(
        p_org_id                IN  NUMBER,
        p_msite_id              IN  NUMBER,
        p_user_type             IN  VARCHAR2,
        x_enabled_flag          OUT NOCOPY VARCHAR2,
        p_notif_name            IN  VARCHAR2,
        x_wf_message_name       OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER
) IS
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_org_id_flag VARCHAR2(1);
    l_msite_id_flag VARCHAR2(1);
    l_user_type_flag VARCHAR2(1);
    l_enabled_flag VARCHAR2(1);
    l_menabled_flag VARCHAR2(1);
    l_notif_setup_id NUMBER;
    --l_msg_sql VARCHAR2(2000);
    l_wf_msg_name VARCHAR2(30);
    l_all_msite_flag VARCHAR2(1) := 'Y';
    l_all_org_id_flag VARCHAR2(1) := 'Y';
    l_all_user_type_flag VARCHAR2(1) := 'Y';
    l_msite_csr t_genref;
    l_wfmsg_rec WFMSG_REC_TYPE;
    l_wfmsg_tbl WFMSG_TBL_TYPE;
    l_org_tbl WFMSG_TBL_TYPE;
    l_user_type_tbl WFMSG_TBL_TYPE;
    l_idx NUMBER := 1;
BEGIN
 debug('retrieve_msg_mapping 1');
    get_notif_metadata(
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	x_return_status		=> l_return_status,
	x_notif_setup_id	=> l_notif_setup_id,
	p_notification_name	=> p_notif_name,
	x_org_id_flag		=> l_org_id_flag,
	x_msite_id_flag		=> l_msite_id_flag,
	x_user_type_flag	=> l_user_type_flag,
	x_enabled_flag		=> l_menabled_flag);

    if( l_return_status = FND_API.G_RET_STS_ERROR ) then
	raise FND_API.G_EXC_ERROR;
    elsif( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

 debug('retrieve_msg_mapping 2');

    if( l_msite_id_flag = 'Y' AND l_org_id_flag = 'Y' and l_user_type_flag = 'Y' ) then
        debug('retrieve_msg_mapping Y Y Y 1');
        find_msite(p_msite_id, l_notif_setup_id, l_wfmsg_tbl);
        if( l_wfmsg_tbl.COUNT > 0 ) THEN
        debug('retrieve_msg_mapping Y Y Y 2');
	    get_msgname_by_orgusertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_org_id, p_user_type, l_wfmsg_tbl);
        else
        debug('retrieve_msg_mapping Y Y Y 3');
            find_all_msite( l_notif_setup_id, l_wfmsg_tbl);
	    if( l_wfmsg_tbl.COUNT > 0 ) THEN
        debug('retrieve_msg_mapping Y Y Y 4');
		  get_msgname_by_orgusertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_org_id, p_user_type, l_wfmsg_tbl);
	    else
        debug('retrieve_msg_mapping Y Y Y 5');
		  get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
            END IF;
	END IF;
    elsif( l_msite_id_flag = 'Y' AND l_org_id_flag = 'Y' AND l_user_type_flag = 'N' ) then
	find_msite(p_msite_id, l_notif_setup_id, l_wfmsg_tbl);
        if( l_wfmsg_tbl.COUNT > 0 ) THEN
	   get_msg_name_by_org(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_org_id, l_wfmsg_tbl);
	else
            find_all_msite( l_notif_setup_id, l_wfmsg_tbl);
	    if( l_wfmsg_tbl.COUNT > 0 ) then
	        get_msg_name_by_org(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_org_id, l_wfmsg_tbl);
	    else
		get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	    END IF;
	END IF;
    elsif( l_msite_id_flag = 'Y' AND l_org_id_flag = 'N' AND l_user_type_flag = 'Y' ) then
        debug('retrieve_msg_mapping Y N Y 1');
	find_msite(p_msite_id, l_notif_setup_id, l_wfmsg_tbl);
        debug('retrieve_msg_mapping Y N Y 2');
	if( l_wfmsg_tbl.COUNT > 0) then
        debug('retrieve_msg_mapping Y N Y 3');
	   get_msg_name_by_usertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_user_type, l_wfmsg_tbl);
	else
        debug('retrieve_msg_mapping Y N Y 4');
           find_all_msite( l_notif_setup_id, l_wfmsg_Tbl);
	   if( l_wfmsg_tbl.COUNT > 0 ) THEN
        debug('retrieve_msg_mapping Y N Y 5');
	       get_msg_name_by_usertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_user_type, l_wfmsg_tbl);
	   else
        debug('retrieve_msg_mapping Y N Y 6');
	       get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	   END IF;
	END IF;
    elsif( l_msite_id_flag = 'Y' AND l_org_id_flag = 'N' AND l_user_type_flag = 'N' ) then
	find_msite(p_msite_id, l_notif_setup_id, l_wfmsg_tbl);
        if( l_wfmsg_tbl.COUNT > 0 ) THEN
           l_wf_msg_name := l_wfmsg_tbl(1).message_name;
	else
           find_all_msite( l_notif_setup_id, l_wfmsg_tbl);
	   if( l_wfmsg_tbl.COUNT > 0 ) THEN
	       l_wf_msg_name := l_wfmsg_tbl(1).message_name;
               l_enabled_flag := l_wfmsg_tbl(1).enabled_flag;
	   else
	       get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	   END IF;
	END IF;
    elsif( l_msite_id_flag = 'N' AND l_org_id_flag = 'Y' AND l_user_type_flag = 'Y' ) then
        find_org_no_msite(p_org_id, l_notif_setup_id, l_wfmsg_tbl);
	if( l_wfmsg_tbl.COUNT > 0 ) THEN
	    get_msg_name_by_usertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_user_type, l_wfmsg_tbl);
	else
	    find_all_org_no_msite(l_notif_setup_id, l_wfmsg_tbl);
	    if( l_wfmsg_tbl.COUNT > 0) THEN
		get_msg_name_by_usertype(l_wf_msg_name, l_enabled_flag, l_notif_setup_id, p_user_type, l_wfmsg_tbl);
	    else
	        get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	    end if;
	end if;
    elsif( l_msite_id_flag = 'N' AND l_org_id_flag = 'Y' AND l_user_type_flag = 'N' ) then
	find_org_no_msite(p_org_id, l_notif_setup_id, l_wfmsg_tbl);
	if( l_wfmsg_tbl.COUNT > 0 ) then
	    l_wf_msg_name := l_wfmsg_tbl(1).message_name;
	    l_enabled_flag := l_wfmsg_tbl(1).enabled_flag;
        else
	    find_all_org_no_msite(l_notif_setup_id, l_wfmsg_tbl);
	    if( l_wfmsg_tbl.COUNT > 0 ) THEN
	        l_wf_msg_name := l_wfmsg_tbl(1).message_name;
	        l_enabled_flag := l_wfmsg_tbl(1).enabled_flag;
	    else
		get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	    end if;
	END IF;
    elsif( l_msite_id_flag = 'N' AND l_org_id_flag = 'N' AND l_user_type_flag = 'Y' ) then
	find_user_type_only(p_user_type, l_notif_setup_id, l_wfmsg_tbl);
	if( l_wfmsg_tbl.COUNT > 0 ) then
	    l_wf_msg_name := l_wfmsg_tbl(1).message_name;
	    l_enabled_flag := l_wfmsg_tbl(1).enabled_flag;
        else
	    find_all_user_type_only(l_notif_setup_id, l_wfmsg_tbl);
	    if( l_wfmsg_tbl.COUNT > 0 ) THEN
	        l_wf_msg_name := l_wfmsg_tbl(1).message_name;
	        l_enabled_flag := l_wfmsg_tbl(1).enabled_flag;
	    else
		get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	    end if;
	END IF;
    elsif( l_msite_id_flag = 'N' AND l_org_id_flag = 'N' AND l_user_type_flag = 'N' ) then
	BEGIN
	   select message_name, enabled_flag
	   into l_wf_msg_name, l_enabled_flag
	   from IBE_WF_NOTIF_MSG_MAPS
	   where notif_setup_id = l_notif_setup_id
	   AND default_msg_map_flag <> 'Y'
	   and rownum < 2;
	EXCEPTION
	   when NO_DATA_FOUND THEN
	      get_default_msg(l_wf_msg_name, l_enabled_flag, l_notif_setup_id);
	END;
    end if;
    x_wf_message_name := l_wf_msg_name;
    x_enabled_flag := l_enabled_flag;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
    x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_MSG_MAP_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('NOTIF', p_notif_name);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count=> x_msg_count, p_data => x_msg_data);
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Retrieve_Msg_Mapping');
        END IF;

        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
        x_msg_data := FND_MSG_PUB.GET(1, FND_API.G_FALSE);
END Retrieve_Msg_Mapping;

procedure Get_Notif_Metadata
(
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_notif_setup_id    OUT NOCOPY NUMBER,
    p_notification_name IN  VARCHAR2,
    x_org_id_flag       OUT NOCOPY VARCHAR2,
    x_msite_id_flag     OUT NOCOPY VARCHAR2,
    x_user_type_flag    OUT NOCOPY VARCHAR2,
    x_enabled_flag      OUT NOCOPY VARCHAR2
) IS
    l_org_id_flag VARCHAR2(1);
    l_msite_id_flag VARCHAR2(1);
    l_user_type_flag VARCHAR2(1);
    l_enabled_flag VARCHAR2(1);
    l_notif_setup_id NUMBER;
BEGIN

    select org_id_flag, msite_id_flag, enabled_flag, notif_setup_id, user_type_flag
    into l_org_id_flag, l_msite_id_flag, l_enabled_flag, l_notif_setup_id, l_user_type_flag
    from ibe_wf_notif_setup
    where notification_name = p_notification_name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_org_id_flag := l_org_id_flag;
    x_msite_id_flag := l_msite_id_flag;
    x_user_type_flag := l_user_type_flag;
    x_enabled_flag := l_enabled_flag;
    x_notif_setup_id := l_notif_setup_id;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
    when NO_DATA_FOUND then
       FND_MESSAGE.SET_NAME('IBE', 'IBE_WF_NOTIF_NAME_NOT_FOUND');
       FND_MESSAGE.SET_TOKEN('NAME', p_notification_name);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Get_Notif_Metadata;


END IBE_WF_MSG_MAPPING_PVT;

/
