--------------------------------------------------------
--  DDL for Package Body QA_SS_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_OM" as
/* $Header: qltssomb.plb 120.1 2006/01/30 04:53:30 srhariha noship $ */

function are_om_header_plans_applicable (
		P_So_Header_Id IN NUMBER DEFAULT NULL
	)
	Return VARCHAR2
 IS
    plan_applicable VARCHAR2(5) := 'N';

	-- This cursor is to verify if there is data in qr for
	-- the given so header id
    CURSOR om_plans_cur IS
	SELECT 'Y'
	from QA_RESULTS QR
	where QR.So_Header_Id = P_So_Header_Id
	AND Rownum <= 1;

 BEGIN
	if (p_so_header_id is null) Then
		return 'N';
	end if;
	if (not fnd_function.test('QA_SS_REST_VQR')) then
		return 'N';
	end if; -- function security. if test returns false,return N

	open om_plans_cur;
	fetch om_plans_cur into plan_applicable;
	close om_plans_cur;
	Return plan_applicable;

 END are_om_header_plans_applicable;
--------------------------------------------------------------------------
function are_om_lines_plans_applicable (
		P_So_Header_Id IN NUMBER DEFAULT NULL,
		P_Item_Id IN NUMBER DEFAULT NULL
	)
	Return VARCHAR2
 IS

    plan_applicable VARCHAR2(5) := 'N';

	-- This cursor sees if there is row in qr for the
	-- given so header id and item id combination
    CURSOR om_plans_cur IS
	SELECT 'Y'
	from QA_RESULTS QR
	where QR.So_Header_Id = P_So_Header_Id
	AND QR.Item_Id = p_item_id
	AND Rownum <= 1;

 BEGIN
	If (p_item_id is Null) OR (p_so_header_id is Null) Then
		Return 'N';
	end if;
	if (not fnd_function.test('QA_SS_REST_VQR')) then
		return 'N';
	end if; -- function security. if test returns false,return N

	open om_plans_cur;
	fetch om_plans_cur into plan_applicable;
	close om_plans_cur;
	Return plan_applicable;

 END are_om_lines_plans_applicable;
--------------------------------------------------------------------------

procedure om_header_to_quality (
			PK1 IN VARCHAR2 DEFAULT NULL, --so header id
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
			c_outputs1 OUT NOCOPY VARCHAR2,
			c_outputs2 OUT NOCOPY VARCHAR2,
			c_outputs3 OUT NOCOPY VARCHAR2,
			c_outputs4 OUT NOCOPY VARCHAR2,
			c_outputs5 OUT NOCOPY VARCHAR2,
			c_outputs6 OUT NOCOPY VARCHAR2,
			c_outputs7 OUT NOCOPY VARCHAR2,
			c_outputs8 OUT NOCOPY VARCHAR2,
			c_outputs9 OUT NOCOPY VARCHAR2,
			c_outputs10 OUT NOCOPY VARCHAR2)

 IS
	plan_tab plan_tab_type;
	i number := 0;

	-- Fetch plans matching the so header id criteria
	-- also get the plan name, description and type(meaning)
	CURSOR om_plans_cur IS
	SELECT distinct qr.plan_id, qp.name, qp.description, fcl.meaning
	from QA_RESULTS QR, qa_plans qp, fnd_common_lookups fcl
	where QR.So_Header_Id = to_number(Pk1)
	and qr.plan_id = qp.plan_id
	and qp.plan_type_code = fcl.lookup_code
	and fcl.lookup_type = 'COLLECTION_PLAN_TYPE'
	order by qp.name;

 BEGIN
 if (icx_sec.validatesession) then
	FOR om_rec IN om_plans_cur LOOP
		i := i+1;
		plan_tab(i).plan_id := om_rec.plan_id;
		plan_tab(i).name := om_rec.name;
		plan_tab(i).description := om_rec.description;
		plan_tab(i).meaning := om_rec.meaning;
	end loop;

	List_OM_Plans(plan_tab, pk1, null);
     end if; -- end icx validate session
 EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in procedure om_headers_to_quality');
            htp.p(SQLERRM);

 END om_header_to_quality;

------------------------------------------------------------------------------------------

procedure om_lines_to_quality (
			PK1 IN VARCHAR2 DEFAULT NULL,--so header id
			PK2 IN VARCHAR2 DEFAULT NULL,--so line id(not used)
			PK3 IN VARCHAR2 DEFAULT NULL,--item id
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
			c_outputs1 OUT NOCOPY VARCHAR2,
			c_outputs2 OUT NOCOPY VARCHAR2,
			c_outputs3 OUT NOCOPY VARCHAR2,
			c_outputs4 OUT NOCOPY VARCHAR2,
			c_outputs5 OUT NOCOPY VARCHAR2,
			c_outputs6 OUT NOCOPY VARCHAR2,
			c_outputs7 OUT NOCOPY VARCHAR2,
			c_outputs8 OUT NOCOPY VARCHAR2,
			c_outputs9 OUT NOCOPY VARCHAR2,
			c_outputs10 OUT NOCOPY VARCHAR2)

 IS
	plan_tab plan_tab_type;
	i number := 0;

	-- Fetch plans matching the so header id and itemid criteria
	-- also get the plan name, description and type(meaning)
	CURSOR om_plans_cur IS
	SELECT distinct qr.plan_id, qp.name, qp.description, fcl.meaning
	from QA_RESULTS QR, qa_plans qp, fnd_common_lookups fcl
	where QR.So_Header_Id = to_number(Pk1)
	AND   qr.item_id = to_number(pk3)
	and qr.plan_id = qp.plan_id
	and  qp.plan_type_code = fcl.lookup_code
	and fcl.lookup_type = 'COLLECTION_PLAN_TYPE'
	order by qp.name;
	-- we do not use pk2 which is so_line_id
	-- becos we base search on so_header and item only


 BEGIN
 if (icx_sec.validatesession) then
	-- if we get to this level, then item should be non-null
	-- pk3 is the item id
	if (pk3 is not null) then
		FOR om_rec IN om_plans_cur LOOP
       			i := i+1;
			plan_tab(i).plan_id := om_rec.plan_id;
			plan_tab(i).name := om_rec.name;
			plan_tab(i).description := om_rec.description;
			plan_tab(i).meaning := om_rec.meaning;
		end loop;

		List_OM_Plans(plan_tab, pk1, pk3);
 	end if; -- end checking non null pk3

     end if; -- end icx validate session
 EXCEPTION
        WHEN OTHERS THEN
            htp.p('Exception in procedure om_lines_to_quality');
            htp.p(SQLERRM);

 END om_lines_to_quality;

------------------------------------------------------------------------------------------

procedure List_OM_Plans ( plan_tab IN plan_tab_type,
			  P_So_Header_Id IN NUMBER Default Null,
			  P_Item_Id IN NUMBER Default Null)
IS
	l_language_code varchar2(30);
	no_of_plans NUMBER;
	pid_i NUMBER;
	pname varchar2(40);
	pdesc varchar2(30);
	ptype varchar2(30);
	viewurl varchar2(5000);
	row_color varchar2(10) := 'BLUE';

	om_where_cl varchar2(2000);

BEGIN
 if (icx_sec.validatesession) then
	l_language_code := icx_sec.getid(icx_sec.pv_language_code);

            htp.htmlOpen;
	    htp.p('<BODY bgcolor=#cccccc>');
            htp.formOpen('');
            htp.br;
            htp.tableOpen(cborder=>'BORDER=2', cattributes=>'CELLPADDING=2');
	    htp.tableCaption(fnd_message.get_string('QA','QA_SS_COLL_PLANS'));
            htp.tableRowOpen (cattributes=>'BGCOLOR="#336699"');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                    fnd_message.get_string('QA', 'QA_SS_CP_HEADING')
                    || '</font>', calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA', 'QA_SS_DESC'), calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                    'Type'|| '</font>', calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA', 'QA_SS_VIEW_BUTTON')|| '</font>', calign=>'CENTER');
            htp.tableRowClose;
            htp.p('<TR></TR><TR></TR>');

	    -- Construct the where clause here
	    om_where_cl := 'so_header_id='||p_so_header_id;

            -- Bug 5003507. R12 Performance SQL Literals.
            -- Comment out literal usage in an obsolete code.
            -- srhariha. Mon Jan 30 04:47:02 PST 2006

	    --if (p_item_id is not null) then
	    --     om_where_cl := om_where_cl || ' AND '
	    --		   || 'item_id=' || p_item_id;
	    --end if; -- end p_item_id check

	    om_where_cl := wfa_html.conv_special_url_chars(om_where_cl);

	 -- Loop goes in here
            no_of_plans := plan_tab.count;
            For i in 1..no_of_plans
            Loop
                    pid_i := plan_tab(i).plan_id;

                viewurl := 'qa_ss_core.VQR_Frames?plan_id_i='|| pid_i
				 || '&'
			         || 'ss_where_clause='||om_where_cl;

                pname := substr(plan_tab(i).name,1,30);
                pdesc := NVL(substr(plan_tab(i).description,1,20), '&nbsp');
                ptype := NVL(substr(plan_tab(i).meaning,1,20), '&nbsp');

		IF (row_color = 'BLUE') THEN
	                htp.tableRowOpen(cattributes=>'BGCOLOR="#99CCFF"');
			row_color := 'WHITE';
		ELSE
			htp.tableRowOpen(cattributes=>'BGCOLOR="#FFFFFF"');
			row_color := 'BLUE';
		END IF; -- end if for row color

                htp.tableData(pname);
                htp.tableData(pdesc);
                htp.tableData(ptype);

                htp.tableData(htf.anchor(viewurl, fnd_message.get_string('QA','QA_SS_VIEW_BUTTON'), cattributes=>'TARGET="viewwin"'));


            End Loop; -- end of forloop for all rows in list of plans
		htp.tableClose;
		htp.formClose;
		htp.bodyClose;
		htp.htmlClose;

 end if; -- end icx validate session

EXCEPTION
	 WHEN OTHERS THEN
            htp.p('Exception in procedure qa_ss_om.list_om_plans');
            htp.p(SQLERRM);

 END List_OM_Plans;


function is_om_header_plan_applicable (
		x_Pid IN NUMBER,
		x_so_header_id IN VARCHAR2 default null)
Return VARCHAR2
IS
	plan_applicable VARCHAR2(5) := 'N';
    l_mtl_sales_ord_id NUMBER := -99;

	CURSOR om_plans_cur(p_mtl_sales_ord_id IN NUMBER) IS
	Select 'Y'
	From QA_RESULTS QR
	Where QR.So_header_id = p_mtl_sales_ord_id
	AND QR.plan_id = x_Pid;

BEGIN
	if (x_so_header_id is null) then
		return 'N';
	end if;

        l_mtl_sales_ord_id :=
		qa_results_interface_pkg.OEHeader_to_MTLSales
			( x_so_header_id );

	open om_plans_cur (l_mtl_sales_ord_id);
	fetch om_plans_cur into plan_applicable;
	close om_plans_cur;
	Return plan_applicable;
END;


function is_om_lines_plan_applicable (
		x_Pid IN NUMBER,
		x_so_header_id IN VARCHAR2 default null,
		x_Item_Id in VARCHAR2 default null )
Return VARCHAR2
IS
	plan_applicable VARCHAR2(5) := 'N';

	CURSOR om_plans_cur IS
	Select 'Y'
	From QA_RESULTS QR
	Where QR.so_header_id = x_so_header_id
	AND  QR.Item_Id = x_item_id
	AND  QR.Plan_ID = x_Pid;

BEGIN
	If (x_item_id is NULL) or (x_so_header_id is NULL) THEN
		Return 'N';
	End If;
	open om_plans_cur;
	fetch om_plans_cur into plan_applicable;
	close om_plans_cur;
	Return plan_applicable;
END;



end qa_ss_om;


/
