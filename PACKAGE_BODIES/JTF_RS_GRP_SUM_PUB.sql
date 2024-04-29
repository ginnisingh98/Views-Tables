--------------------------------------------------------
--  DDL for Package Body JTF_RS_GRP_SUM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GRP_SUM_PUB" AS
/* $Header: jtfrssgb.pls 120.1 2006/02/09 15:48:00 baianand noship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_RS_GRP_SUM_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Get group details for Group Summary Screen (jsp)
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/30/2001    NSINGHAI    Created
--      04/17/2002	  SURAWAT	  Modified - Added the logic for "Last"
--                                function. At the beginning of each new set, the
--                                previous set is flushed out of the PL/SQL table.
--      07/15/2002    ASACHAN     Fixed problem of next button getting wrongly
--                                disabled.
--    End of Comments
--
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_RS_GRP_SUM_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfrssgb.pls';

   G_NEW_LINE        VARCHAR2(02) := FND_GLOBAL.Local_Chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;

-- ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get Group Summary
--    type           : public.
--    function       : Get the Groups summary information
--    pre-reqs       : depends on jtf_rs_groups_vl
--    parameters     :
-- end of comments

procedure Get_Group
(   p_range_low           IN NUMBER,
    p_range_high          IN NUMBER,
    p_called_from         IN VARCHAR2,
    p_user_id             IN NUMBER,
    p_group_name          IN VARCHAR2,
    p_group_number        IN VARCHAR2,
    p_group_desc          IN VARCHAR2,
    p_group_email         IN VARCHAR2,
    p_from_date           IN VARCHAR2,
    p_to_date             IN VARCHAR2,
    p_date_format         IN VARCHAR2,
    p_group_id            IN NUMBER,
    p_group_usage         IN VARCHAR2,
    x_total_rows          OUT NOCOPY NUMBER,
    x_result_tbl          OUT NOCOPY grp_sum_tbl_type)

IS

   cursor main_uid_cur(l_uid number) is
          select mem.group_id group_id,
		 grp.group_name group_name,
                 upper(grp.group_name) u_group_name,
		 grp.group_desc group_desc,
		 grp.group_number group_number,
		 grp.start_date_active start_date_active,
                 grp.end_date_active end_date_active
            from jtf_rs_group_members mem,
		 jtf_rs_groups_vl grp
           where mem.resource_id in
                     (select rsc.resource_id
		      from   jtf_rs_resource_extns rsc
		      where  rsc.user_id  = l_uid)
            and nvl(mem.delete_flag,'N') = 'N'
	    and  mem.group_id = grp.group_id
            order by u_group_name, mem.group_id  ;

      r_main_cur main_uid_cur%rowtype;

      cursor main_qf_cur(l_group varchar2) is
	     select group_id,
		    group_name,
                    upper(group_name) u_group_name,
		    group_desc,
		    group_number ,
		    start_date_active,
		    end_date_active
     	      from  jtf_rs_groups_vl
	      where upper(group_name) like l_group
	      union
	     select group_id,
		    group_name,
                    upper(group_name) u_group_name,
		    group_desc,
		    group_number,
		    start_date_active,
		    end_date_active
     	      from  jtf_rs_groups_vl
	      where group_number like l_group
/*	      union
	     select group_id,
		    group_name,
                    upper(group_name) u_group_name,
		    group_desc,
		    group_number,
		    start_date_active,
		    end_date_active
     	      from  jtf_rs_groups_vl
	      where group_id = l_grp_id
*/	      order by u_group_name, group_id ;

      cursor get_parent_group(l_par_group_id number) is
             select grl.related_group_id,
		    grp.group_name,
                    upper(grp.group_name) u_group_name
             from   jtf_rs_grp_relations grl,
		    jtf_rs_groups_vl grp
             where  grl.group_id = l_par_group_id
             and    trunc(sysdate) between grl.start_date_active and nvl(grl.end_date_active,sysdate)
             and    nvl(grl.delete_flag,'N') = 'N'
             and    grl.related_group_id = grp.group_id
             order by u_group_name, grl.related_group_id ;

      r_get_parent_group get_parent_group%rowtype;

      cursor get_child_group(l_child_group_id number) is
             select grl.group_id,
		    grp.group_name,
                    upper(grp.group_name) u_group_name
             from   jtf_rs_grp_relations grl,
		    jtf_rs_groups_vl grp
             where  grl.related_group_id = l_child_group_id
             and    trunc(sysdate) between grl.start_date_active and nvl(grl.end_date_active,sysdate)
             and    nvl(grl.delete_flag,'N') = 'N'
             and    grl.group_id = grp.group_id
             order by u_group_name,grl.group_id ;

       r_get_child_group get_child_group%rowtype;

    l_date_format                varchar2(15) := p_date_format ;
    l_index                      NUMBER := 0;
    l_user_id                    NUMBER := nvl(FND_PROFILE.VALUE('USER_ID'),-1);
    l_group_name                 VARCHAR2(70) := UPPER(p_group_name)||'%';
    l_group_number               VARCHAR2(40)  := p_group_number ||'%';
    l_group_id                   NUMBER        := p_group_id;
    l_group_desc                 VARCHAR2(250) := UPPER(p_group_desc) || '%';
    l_group_email                VARCHAR2(250) := UPPER(p_group_email) || '%';
    l_from_date                  VARCHAR2(15)  := to_char(to_date(p_from_date,p_date_format),'DD-MM-RRRR');
    l_to_date                    VARCHAR2(15)  := to_char(to_date(p_to_date,p_date_format),'DD-MM-RRRR');
    l_range_high                 NUMBER;
    TYPE group_qry_cur           IS REF CURSOR;
    main_as_cur                  group_qry_cur;
    l_qry                        VARCHAR2(2000);
    l_bind_counter               NUMBER := 1;
    TYPE bind_rec_type IS record (bind_value varchar2(500));
    TYPE bind_tbl_type IS table OF bind_rec_type
      INDEX BY binary_integer;
    bind_table                   bind_tbl_type;
    i                            integer := 1;
    l_group_usage                VARCHAR2(240) := p_group_usage;

    init_tbl_type		 grp_sum_tbl_type;

	l_has_more_records			BOOLEAN := FALSE;
BEGIN
    x_total_rows := 1;
    l_range_high := p_range_high + 1;

    IF (p_called_from = 'DEFAULT' )THEN
 	   IF p_user_id is null THEN
          l_user_id    := nvl(FND_PROFILE.VALUE('USER_ID'),-1);
       ELSE l_user_id  := p_user_id;
	   END IF;
    END IF;
    IF (p_called_from = 'AS') THEN
	l_qry := ' ';
        l_qry := ' select grp.group_id, grp.group_name, upper(grp.group_name) u_group_name, grp.group_desc, grp.group_number, grp.start_date_active, grp.end_date_active ';
--	l_qry := l_qry||'  from  jtf_rs_groups_vl where upper(group_name) like :b_group_name ' ;
--	i := l_bind_counter ;
--	bind_table(i).bind_value := l_group_name;

	IF (p_group_usage IS NULL) THEN
	  l_qry := l_qry||'  from  jtf_rs_groups_vl grp ';
        ELSE
	  l_qry := l_qry||'  from  jtf_rs_group_usages gu, jtf_rs_groups_vl grp ';
        END IF;

	l_qry := l_qry||'  where upper(grp.group_name) like :b_group_name ' ;
        i := l_bind_counter ;
        bind_table(i).bind_value := l_group_name;

        IF p_group_usage IS NOT NULL THEN
	  l_qry := l_qry||' and gu.usage    = :b_usage ';
	  l_qry := l_qry||' and grp.group_id = gu.group_id ';
	  l_bind_counter := l_bind_counter + 1 ;
	  i := l_bind_counter ;
	  bind_table(i).bind_value := l_group_usage ;
        END IF;

        IF p_group_number IS NOT NULL THEN
	  --l_qry := l_qry||' and group_number like '||''''||l_group_number||'''';
	  l_qry := l_qry||' and grp.group_number like :b_group_number ';
	  l_bind_counter := l_bind_counter + 1 ;
	  i := l_bind_counter ;
	  bind_table(i).bind_value := l_group_number ;
        END IF;

        IF p_group_desc IS NOT NULL THEN
	  --l_qry := l_qry||' and upper(group_desc) like '||''''||l_group_desc||'''' ;
	  l_qry := l_qry||' and upper(grp.group_desc) like :b_group_desc ' ;
	  l_bind_counter := l_bind_counter + 1 ;
	  i := l_bind_counter ;
	  bind_table(i).bind_value := l_group_desc ;
        END IF;

	IF p_group_email IS NOT NULL THEN
	  --l_qry := l_qry||' and upper(email_address) like '||''''||l_group_email||'''' ;
	  l_qry := l_qry||' and upper(grp.email_address) like :b_group_email ' ;
	  l_bind_counter := l_bind_counter + 1 ;
	  i := l_bind_counter ;
	  bind_table(i).bind_value := l_group_email ;
	END IF;

	IF ((p_from_date IS NOT NULL) OR (p_to_date IS NOT NULL))THEN
	  IF p_from_date IS NULL THEN
	    l_from_date := '01-01-1800';
          ELSE l_from_date := l_from_date ;
	  END IF;

	  IF p_to_date IS NULL THEN
	    l_to_date := '31-12-4712';
          ELSE l_to_date := l_to_date ;
	  END IF;

--        l_qry := l_qry||' and (( start_date_active between to_date('||''''||l_from_date||''''||','||''''||'DD-MM-RRRR'||''''
--			||') and to_date('||''''||l_to_date||''''||','||''''||'DD-MM-RRRR'||''''||'))';
--	  l_qry := l_qry||' OR (start_date_active < to_date('||''''||l_from_date||''''||','||''''||'DD-MM-RRRR'||''''
--			||') and (end_date_active IS NULL OR ';
--	  l_qry := l_qry||' end_date_active >= to_date('||''''||l_from_date||''''||','||''''||'DD-MM-RRRR'||''''||')))) ';

	  l_qry := l_qry||' and (( grp.start_date_active between to_date(:b_from_date '||','||''''||'DD-MM-RRRR'||''''
			||') and to_date(:b_to_date '||','||''''||'DD-MM-RRRR'||''''||'))';
	  l_qry := l_qry||' OR (grp.start_date_active < to_date(:b_from_date '||','||''''||'DD-MM-RRRR'||''''
			||') and (grp.end_date_active IS NULL OR ';
	  l_qry := l_qry||' grp.end_date_active >= to_date(:b_from_date '||','||''''||'DD-MM-RRRR'||''''||')))) ';

	  l_bind_counter := l_bind_counter + 1 ;
	  i := l_bind_counter ;
	  bind_table(i).bind_value := l_from_date ;
	  bind_table(i+1).bind_value := l_to_date ;
	  bind_table(i+2).bind_value := l_from_date ;
	  bind_table(i+3).bind_value := l_from_date ;
        END IF;

        l_qry := l_qry||'  order by u_group_name, grp.group_id ' ;

	l_bind_counter := bind_table.COUNT;

   --   dbms_output.put_line(substr(l_qry,1,200));
   --   dbms_output.put_line(substr(l_qry,201,400));
   --   dbms_output.put_line(substr(l_qry,401,600));

      END IF;

    -- Open Cursor based on passed parameter
    IF (p_called_from = 'QF') THEN
       OPEN main_qf_cur(l_group_name);
    ELSIF (p_called_from = 'AS') THEN
       IF (l_bind_counter = 1) THEN
         OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value;
       ELSIF (l_bind_counter = 2) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value;
       ELSIF (l_bind_counter = 3) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value;
       ELSIF (l_bind_counter = 4) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ;
       ELSIF (l_bind_counter = 5) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ,bind_table(5).bind_value ;
       ELSIF (l_bind_counter = 6) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ,bind_table(5).bind_value, bind_table(6).bind_value;
       ELSIF (l_bind_counter = 7) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ,bind_table(5).bind_value, bind_table(6).bind_value, bind_table(7).bind_value;
       ELSIF (l_bind_counter = 8) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ,bind_table(5).bind_value, bind_table(6).bind_value, bind_table(7).bind_value, bind_table(8).bind_value;
       ELSIF (l_bind_counter = 9) THEN
	 OPEN main_as_cur FOR l_qry USING bind_table(1).bind_value, bind_table(2).bind_value, bind_table(3).bind_value, bind_table(4).bind_value ,bind_table(5).bind_value,
             bind_table(6).bind_value, bind_table(7).bind_value, bind_table(8).bind_value, bind_table(9).bind_value;
       END IF;
    ELSE
       OPEN  main_uid_cur(l_user_id);
    END IF;

    LOOP

		exit when l_has_more_records = TRUE;

         -- Fetch Cursor based on passed parameter
     IF (p_called_from = 'QF') THEN
        FETCH main_qf_cur INTO r_main_cur;
	IF main_qf_cur%notfound THEN
	  x_total_rows := x_total_rows - 1;
	  exit;
        END IF;
     ELSIF (p_called_from = 'AS') THEN
	FETCH main_as_cur INTO r_main_cur;
	IF main_as_cur%notfound THEN
	  x_total_rows := x_total_rows - 1;
	  exit;
        END IF;
     ELSE
	FETCH main_uid_cur INTO r_main_cur;
	IF main_uid_cur%notfound THEN
	  x_total_rows := x_total_rows - 1;
	  exit;
        END IF;
     END IF;

     exit when x_total_rows = l_range_high;

     OPEN get_parent_group(r_main_cur.group_id);
     r_get_parent_group.group_name := NULL;
     r_get_parent_group.related_group_id := NULL;
     FETCH  get_parent_group into r_get_parent_group;
     CLOSE get_parent_group;

     OPEN get_child_group(r_main_cur.group_id);
     FETCH  get_child_group into r_get_child_group;

     IF (get_child_group%NOTFOUND) THEN
        IF (x_total_rows between p_range_low and p_range_high) OR (p_range_high = -1) THEN
           IF (p_range_high = -1) AND (mod(l_index, p_range_low) = 0) THEN
	      x_result_tbl := init_tbl_type;
	      l_index := 0;
	   END IF;

           l_index := l_index + 1;
	   x_result_tbl(l_index).group_id := r_main_cur.group_id ;
	   x_result_tbl(l_index).group_name := r_main_cur.group_name ;
	   x_result_tbl(l_index).group_desc := r_main_cur.group_desc ;
	   x_result_tbl(l_index).group_number := r_main_cur.group_number ;
	   x_result_tbl(l_index).start_date_active := r_main_cur.start_date_active ;
	   x_result_tbl(l_index).end_date_active := r_main_cur.end_date_active ;
	   x_result_tbl(l_index).start_date_active := r_main_cur.start_date_active ;
	   x_result_tbl(l_index).parent_group := r_get_parent_group.group_name ;
	   x_result_tbl(l_index).parent_group_id := r_get_parent_group.related_group_id ;
        END IF;

	x_total_rows := x_total_rows + 1;

     ELSE
       LOOP
        IF (x_total_rows between p_range_low and p_range_high) OR (p_range_high = -1) THEN
           IF (p_range_high = -1) AND (mod(l_index, p_range_low) = 0) THEN
	      x_result_tbl := init_tbl_type;
	      l_index := 0;
	   END IF;

           l_index := l_index + 1;
	   x_result_tbl(l_index).group_id := r_main_cur.group_id ;
	   x_result_tbl(l_index).group_name := r_main_cur.group_name ;
	   x_result_tbl(l_index).group_desc := r_main_cur.group_desc ;
	   x_result_tbl(l_index).group_number := r_main_cur.group_number ;
	   x_result_tbl(l_index).start_date_active := r_main_cur.start_date_active ;
	   x_result_tbl(l_index).end_date_active := r_main_cur.end_date_active ;
	   x_result_tbl(l_index).start_date_active := r_main_cur.start_date_active ;
	   x_result_tbl(l_index).parent_group := r_get_parent_group.group_name ;
	   x_result_tbl(l_index).parent_group_id := r_get_parent_group.related_group_id ;
	   x_result_tbl(l_index).child_group := r_get_child_group.group_name ;
	   x_result_tbl(l_index).child_group_id := r_get_child_group.group_id ;
         END IF;

 	 x_total_rows := x_total_rows + 1;
	 FETCH get_child_group into r_get_child_group;
	 exit when get_child_group%notfound;
     IF (x_total_rows = l_range_high) THEN
		l_has_more_records := TRUE;
		exit;
	 END IF;
	END LOOP;
      END IF;
      CLOSE get_child_group;
    END LOOP; -- of Fetch Cursor based on passed parameter

    IF (p_called_from = 'QF') THEN
       CLOSE main_qf_cur ;
    ELSIF (p_called_from = 'AS') THEN
       CLOSE main_as_cur ;
    ELSE
       CLOSE  main_uid_cur;
    END IF;

END Get_Group;

END JTF_RS_GRP_SUM_PUB;

/
