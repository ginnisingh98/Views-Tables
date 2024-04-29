--------------------------------------------------------
--  DDL for Package Body QA_SS_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SS_CORE" as
/* $Header: qltsscob.plb 120.0.12010000.3 2015/11/09 22:15:00 ntungare ship $ */

/*

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- CHANGE RECORD
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 1. Sep 13, 99  Mandatory field validation for context elements removed
            Change done because, context element could be null, and then
            the user cannot save the data to the plan
            Talked to Manish about this, and felt this may be better to do
            PROCEDURE enter_results altered (BUG 998445)

  2. Bug 977968
     Function Evaluate_triggers removed unnecessary to_char

  3. Added the HiddenRSMDF form to the eqr webpage (procedure draw_table)

  4. Fixing Bug 995239. Modify procedure VQR_Frames and draw_frames
	Add a local variable l_plan_name. Use a cursor to fetch this
	and use it in the call to pos_upper_banner_sv.PaintUpperBanner
	(Minor performance issue: dont query fnd_messages in pos pkg if not needed.
	 Ayeung is the PO contact for the above).

  5. Bug 999521 fix: Procedure list_plans modified
	Private func  Is_Job_Valid added
  6. Bug 998381: to make send notification work without clicking back button
	I am going to add arguments to the procedure enter_results, and also
	have a hidden html form in that procedure.
	Changes to the procedure draw_table is the elements of the html
	form WORKFLOWDOC are also going to be made hidden elements of
	html form RSMDF. This is done so they will now be transmitted
	to the enter_results procedure.
   7. Removing hardcoded US and using language variable
   8. Also remove US from OA_MEDIA/US and make it OA_MEDIA
   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   --   END CHANGE RECORD
   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*/

-- PRIVATE FUNCTIONS AND PROCEDURES BELOW --
function get_char_prompt(X_char_id IN NUMBER)
	return VARCHAR2
IS
   l_prompt VARCHAR2(50);

	CURSOR c IS
		Select prompt
		From QA_CHARS
		WHERE char_id = X_char_id;

BEGIN
	OPEN c;
	FETCH c INTO l_prompt;
	CLOSE c;

	RETURN l_prompt;
EXCEPTION
	WHEN OTHERS THEN
		IF c%ISOPEN THEN
			CLOSE c;
		END IF;
	htp.p('Exception in private function qa_ss_core.get_char_prompt');
	htp.p(SQLERRM);

END get_char_prompt;
-----------------------------------------------------------------
function Is_Job_Valid (X_Po_Dist_Id IN NUMBER,
			X_Wip_Entity_Id IN NUMBER)
	Return BOOLEAN
IS
	l_ent_type NUMBER;
	l_dummy_var NUMBER;
	valid_ok BOOLEAN := TRUE;
	CURSOR we_type_cur IS
		SELECT entity_type
		FROM WIP_ENTITIES
		WHERE WIP_ENTITY_ID = X_Wip_Entity_Id;

 -- #2382432
 -- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
 -- earlier wip_open_discrete_jobs_val_v
 -- rkunchal Sun Jun 30 22:59:11 PDT 2002

	CURSOR wdj_open_val_cur IS
		SELECT wip_entity_id
		FROM WIP_DISCRETE_JOBS_ALL_V
		WHERE WIP_ENTITY_ID = X_Wip_Entity_Id;

BEGIN
	OPEN we_type_cur;
	FETCH we_type_cur INTO l_ent_type;
	CLOSE we_type_cur;
	IF (l_ent_type = 3) THEN -- closed discrete job
		valid_ok := FALSE; -- not valid for eqr
	END IF;
	IF (l_ent_type = 1) THEN -- open disc job;need more eval
		OPEN wdj_open_val_cur;
		FETCH wdj_open_val_cur INTO l_dummy_var;
		IF wdj_open_val_cur%FOUND THEN
			valid_ok := TRUE;
		ELSE
			valid_ok := FALSE;
			-- set to FALSE only if l_ent_type = 1
			-- AND not in WIP_OPEN_DISCRETE_JOBS_VAL_V
		END IF;
		CLOSE wdj_open_val_cur;
	END IF;
		RETURN valid_ok; -- variable initial value is TRUE

EXCEPTION
	WHEN OTHERS THEN
		IF we_type_cur%ISOPEN THEN
			CLOSE we_type_cur;
		END IF;
		IF wdj_open_val_cur%ISOPEN THEN
			CLOSE wdj_open_val_cur;
		END IF;
	htp.p('Exception in private function qa_ss_core.Is_Job_Valid');
	htp.p(SQLERRM);

END Is_Job_Valid;


FUNCTION get_item_id (x_org_id number, x_item VARCHAR2) return NUMBER is

        id NUMBER;

BEGIN

    --
    -- Bug 2672398.  The original SQL here is too costly.
    -- We should simply use the qa_flex_util package.  It
    -- has an identical function
    -- bso Mon Nov 25 19:06:05 PST 2002
    --
        return qa_flex_util.get_item_id(x_org_id, x_item);
END;


--Following copied from qltutlfb.plb and added as private here
--to avoid dependency (by Ilam)
-- The following function is added to make item_category a collection trigger
-- It can be called from mobile or self service.
-- In mobile, the user will have item_value and not the id but in self service
-- item_id is available. To ensure the scalability, this function takes in
-- both, item_value as well as item_id. It calls get_item_id to get item_id
-- based upon item_value and then uses this to get item_category.
-- anagarwa Tue Sep 18 16:19:08 PDT 2001

PROCEDURE get_item_category_val (p_org_id NUMBER,
                                 p_item_val VARCHAR2 default null,
                                 p_item_id NUMBER default null,
                                 x_category_val OUT NOCOPY VARCHAR2,
                                 x_category_id OUT NOCOPY NUMBER,
                                 p_plan_transaction_id NUMBER default null) IS

l_item_id          NUMBER;
l_category_set_id  NUMBER;
l_category_val     VARCHAR2(1000) := NULL;
l_category_id      NUMBER := NULL;

-- Bug 20963504 suchipat
-- Change cursor query to consider plan_transaction_id
CURSOR category_cur(p_org_id NUMBER, p_item_id NUMBER, p_category_set_id NUMBER, p_plan_transaction_id NUMBER) IS
        select  mck.concatenated_segments,
                mck.category_id
        from    mtl_item_categories mic, mtl_categories_kfv mck,
                qa_plan_collection_triggers qpct
        where   mic.organization_id = p_org_id
        and     mic.category_id = mck.category_id
        and     mic.inventory_item_id =p_item_id
        and     mic.category_set_id = p_category_set_id
        and     qpct.plan_transaction_id = p_plan_transaction_id
        and     mck.concatenated_segments = qpct.low_value;

BEGIN
        -- org_id should never be null
        IF (p_org_id IS NULL) THEN
            RETURN ;
        END IF;

        -- if calling from mobile, then get_item_id
        IF ((p_item_id <0 OR p_item_id IS NULL) AND (p_item_val IS NOT NULL))
	 THEN
            l_item_id := get_item_id(p_org_id, p_item_val);
        ELSE
            l_item_id := p_item_id;
        END IF;

        l_category_set_id :=  FND_PROFILE.VALUE('QA_CATEGORY_SET');

        -- Bug 20963504 suchipat
        OPEN category_cur( p_org_id, l_item_id, l_category_set_id, p_plan_transaction_id);

        FETCH category_cur INTO l_category_val, l_category_id;

        CLOSE category_cur;

	--if cursor did not fetch any rows
	--then l_category_val and l_category_id will have
	--initialized NULL values
	--Do Not Raise Exception Here
	--
	x_category_val  := l_category_val;
	x_category_id	:= l_category_id;

        RETURN;

END;


--------------------------------------------------------------------------------
--
	-- PUBLIC PROCEDURES AND FUNCTIONS BELOW
--
--------------------------------------------------------------------------------
procedure enter_results(
selectbox IN qa_ss_const.var30_table DEFAULT qa_ss_const.def30_tab,
p_col1 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col2 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col3 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col4 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col5 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col6 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col7 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col8 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col9 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col10 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col11 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col12 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col13 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col14 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col15 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col16 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col17 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col18 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col19 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col20 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col21 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col22 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col23 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col24 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col25 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col26 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col27 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col28 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col29 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col30 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col31 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col32 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col33 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col34 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col35 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col36 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col37 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col38 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col39 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col40 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col41 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col42 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col43 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col44 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col45 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col46 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col47 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col48 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col49 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col50 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col51 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col52 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col53 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col54 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col55 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col56 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col57 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col58 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col59 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col60 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col61 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col62 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col63 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col64 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col65 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col66 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col67 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col68 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col69 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col70 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col71 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col72 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col73 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col74 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col75 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col76 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col77 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col78 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col79 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col80 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col81 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col82 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col83 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col84 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col85 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col86 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col87 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col88 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col89 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col90 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col91 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col92 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col93 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col94 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col95 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col96 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col97 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col98 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col99 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col100 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col101 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col102 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col103 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col104 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col105 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col106 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col107 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col108 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col109 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col110 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col111 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col112 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col113 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col114 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col115 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col116 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col117 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col118 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col119 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col120 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col121 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col122 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col123 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col124 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col125 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col126 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col127 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col128 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col129 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col130 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col131 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col132 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col133 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col134 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col135 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col136 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col137 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col138 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col139 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col140 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col141 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col142 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col143 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col144 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col145 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col146 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col147 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col148 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col149 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col150 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col151 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col152 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col153 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col154 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col155 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col156 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col157 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col158 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col159 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col160 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
hid_planid IN NUMBER DEFAULT NULL,
orgz_id IN NUMBER DEFAULT NULL,
txn_num IN NUMBER DEFAULT NULL,
po_agent_id IN NUMBER DEFAULT NULL,
x_source_id IN NUMBER DEFAULT NULL,
x_item_id IN NUMBER DEFAULT NULL,
x_po_header_id IN NUMBER DEFAULT NULL)
IS
    orgz_ex EXCEPTION;
    plan_ex EXCEPTION;
    col_count NUMBER;
    No_problem BOOLEAN;
    l_date_format   varchar2(100);
    charid_tab qa_ss_const.num_table;
    values_tab qa_ss_const.var150_table;
    rows_selected BOOLEAN := FALSE;

    script VARCHAR2(32000); -- out parameter to qltimptb pkg
    tailscript VARCHAR2(32000); -- out parameter to qltimptb pkg
    flg1 NUMBER;
    r NUMBER;

    qri_source_code VARCHAR2(30) := NULL;
    qri_source_line_id NUMBER := NULL;

    l_prompt VARCHAR2(50):=NULL; -- this is qa_chars.prompt column to show
			   -- collection element prompt for error messages

    cursor chars_cur IS
	SELECT qpc.char_id
	FROM qa_plan_chars qpc
	where qpc.plan_id = hid_planid
	AND qpc.enabled_flag = 1
	ORDER BY qpc.prompt_sequence;

BEGIN
if (icx_sec.validatesession) then

	 htp.p('<HTML>');

        htp.p('<HEAD>');
        js.ScriptOpen;
        htp.p('function set_clear_var(inval)
                {
                    if (inval = "N")
                    {
                    parent.buttonsFrame.document.buttonHiddenF.clear_var.value = "N";
                    // alert("value set to " + parent.buttonsFrame.document.buttonHiddenF.clear_var.value);
                    }
                 }');
        js.ScriptClose;
        htp.p('</HEAD>');

        htp.p('<BODY bgcolor="#cccccc">');

	-- BELOW WORKFLOWDOC added for Bug 998381
            htp.p('<FORM ACTION="qa_ss_core.call_workflow" NAME="WORKFLOWDOC" METHOD="POST">');
            htp.formHidden('x_buyer_id', po_agent_id);
            htp.formHidden('x_source_id', x_source_id);
            htp.formHidden('x_plan_id', hid_planid);
            htp.formHidden('x_item_id', x_item_id);
            htp.formHidden('x_po_header_id', x_po_header_id);
            htp.p('</FORM>');


        -- if orgz_id is null, then raise an exception here
        if (orgz_id is NULL) Then
            RAISE orgz_ex;
        end if; -- end orgz_id check

         if (hid_planid is NULL) Then
            RAISE plan_ex;
        end if; -- end hid_planid check

            -- The below is useful for collection import and QLTCORE.pld
            -- uses these values to display contact info etc in CIMDF
            -- Bso  has done those changes
            -- source line id has the fnd_user  userid got thro ICX call
            qri_source_line_id := icx_sec.getID(icx_sec.PV_USER_ID);

         if (txn_num = 100) THEN
                qri_source_code := 'QA_SS_OSP';
         elsif (txn_num = 110) THEN
                qri_source_code := 'QA_SS_SHIP';
         end if;



        l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
        if (l_date_format is NULL) then
            l_date_format := 'DD/MON/RRRR';
        end if;

	col_count := 0;
	FOR char_rec IN chars_cur
	LOOP
		col_count := col_count + 1;
		charid_tab(col_count) := char_rec.char_id;
	END LOOP;
	-- col_count has the no.of cols in the plan

	fnd_date.initialize(l_date_format);  -- to set user mask
	-- fnd_number.initialize(  );
    fnd_message.clear;

        No_problem := TRUE; -- initialize this to true

        SAVEPOINT start_inserting;
        FOR K in 1..qa_ss_const.no_of_rows
        LOOP
                -- Reinitialization of No_problem to TRUE removed here
                -- for usability fix after Aug 11

                -- New code line below
                  --  If selectbox.Exists(K) Then
                    --        htp.p('value of selectbox('||selectbox(K)||') is: ' || selectbox(K));
                      --      htp.nl;
                    -- End If;

             if  (  NOT selectbox.Exists(K) ) Then

                -- if ( selectbox(K) = 'N')  THEN
                        -- htp.p('row ' || to_char(K)|| 'top level filtered'); htp.nl;
                         NULL; -- definitely this is an empty row
                -- else still have to check for empty row?? I dont think so
                /*
                elsif ( is_empty_row    (   K,
                                             charid_tab,
                                             txn_num,
                                            p_col1,
                                            p_col2,
                                            p_col3,
                                            p_col4,
                                            p_col5,
                                            p_col6,
                                            p_col7,
                                            p_col8,
                                            p_col9,
                                            p_col10,
                                            p_col11,
                                            p_col12,
                                            p_col13,
                                            p_col14,
                                            p_col15,
                                            p_col16,
                                            p_col17,
                                            p_col18,
                                            p_col19,
                                            p_col20,
                                            p_col21,
                                            p_col22,
                                            p_col23,
                                            p_col24,
                                            p_col25,
                                            p_col26,
                                            p_col27,
                                            p_col28,
                                            p_col29,
                                            p_col30,
                                            p_col31,
                                            p_col32,
                                            p_col33,
                                            p_col34,
                                            p_col35,
                                            p_col36,
                                            p_col37,
                                            p_col38,
                                            p_col39,
                                            p_col40,
                                            p_col41,
                                            p_col42,
                                            p_col43,
                                            p_col44,
                                            p_col45,
                                            p_col46,
                                            p_col47,
                                            p_col48,
                                            p_col49,
                                            p_col50,
                                            p_col51,
                                            p_col52,
                                            p_col53,
                                            p_col54,
                                            p_col55,
                                            p_col56,
                                            p_col57,
                                            p_col58,
                                            p_col59,
                                            p_col60,
                                            p_col61,
                                            p_col62,
                                            p_col63,
                                            p_col64,
                                            p_col65,
                                            p_col66,
                                            p_col67,
                                            p_col68,
                                            p_col69,
                                            p_col70,
                                            p_col71,
                                            p_col72,
                                            p_col73,
                                            p_col74,
                                            p_col75,
                                            p_col76,
                                            p_col77,
                                            p_col78,
                                            p_col79,
                                            p_col80,
                                            p_col81,
                                            p_col82,
                                            p_col83,
                                            p_col84,
                                            p_col85,
                                            p_col86,
                                            p_col87,
                                            p_col88,
                                            p_col89,
                                            p_col90,
                                            p_col91,
                                            p_col92,
                                            p_col93,
                                            p_col94,
                                            p_col95,
                                            p_col96,
                                            p_col97,
                                            p_col98,
                                            p_col99,
                                            p_col100,
                                            p_col101,
                                            p_col102,
                                            p_col103,
                                            p_col104,
                                            p_col105,
                                            p_col106,
                                            p_col107,
                                            p_col108,
                                            p_col109,
                                            p_col110,
                                            p_col111,
                                            p_col112,
                                            p_col113,
                                            p_col114,
                                            p_col115,
                                            p_col116,
                                            p_col117,
                                            p_col118,
                                            p_col119,
                                            p_col120,
                                            p_col121,
                                            p_col122,
                                            p_col123,
                                            p_col124,
                                            p_col125,
                                            p_col126,
                                            p_col127,
                                            p_col128,
                                            p_col129,
                                            p_col130,
                                            p_col131,
                                            p_col132,
                                            p_col133,
                                            p_col134,
                                            p_col135,
                                            p_col136,
                                            p_col137,
                                            p_col138,
                                            p_col139,
                                            p_col140,
                                            p_col141,
                                            p_col142,
                                            p_col143,
                                            p_col144,
                                            p_col145,
                                            p_col146,
                                            p_col147,
                                            p_col148,
                                            p_col149,
                                            p_col150,
                                            p_col151,
                                            p_col152,
                                            p_col153,
                                            p_col154,
                                            p_col155,
                                            p_col156,
                                            p_col157,
                                            p_col158,
                                            p_col159,
                                            p_col160,
                                            hid_planid ) )
                    THEN
                         htp.p('row ' || to_char(K)|| 'second level filtered'); htp.nl;
                            NULL; -- empty row
                    */
                    ELSE
                   -- proceed with your calls

                   -- New code being added here
		-- htp.p('===============================================================');
		-- htp.nl;
                        r := to_number(selectbox(K));
                        -- r := K;
                        rows_selected := TRUE;
                   -- New code above

                  values_tab(1) := p_col1(r);
                values_tab(2) := p_col2(r);
                values_tab(3) := p_col3(r);
                values_tab(4) := p_col4(r);
                values_tab(5) := p_col5(r);
                values_tab(6) := p_col6(r);
                values_tab(7) := p_col7(r);
                values_tab(8) := p_col8(r);
                values_tab(9) := p_col9(r);
                values_tab(10) := p_col10(r);
                values_tab(11) := p_col11(r);
                values_tab(12) := p_col12(r);
                values_tab(13) := p_col13(r);
                values_tab(14) := p_col14(r);
                values_tab(15) := p_col15(r);
                values_tab(16) := p_col16(r);
                values_tab(17) := p_col17(r);
                values_tab(18) := p_col18(r);
                values_tab(19) := p_col19(r);
                values_tab(20) := p_col20(r);
                values_tab(21) := p_col21(r);
                values_tab(22) := p_col22(r);
                values_tab(23) := p_col23(r);
                values_tab(24) := p_col24(r);
                values_tab(25) := p_col25(r);
                values_tab(26) := p_col26(r);
                values_tab(27) := p_col27(r);
                values_tab(28) := p_col28(r);
                values_tab(29) := p_col29(r);
                values_tab(30) := p_col30(r);
                values_tab(31) := p_col31(r);
                values_tab(32) := p_col32(r);
                values_tab(33) := p_col33(r);
                values_tab(34) := p_col34(r);
                values_tab(35) := p_col35(r);
                values_tab(36) := p_col36(r);
                values_tab(37) := p_col37(r);
                values_tab(38) := p_col38(r);
                values_tab(39) := p_col39(r);
                values_tab(40) := p_col40(r);
                values_tab(41) := p_col41(r);
                values_tab(42) := p_col42(r);
                values_tab(43) := p_col43(r);
                values_tab(44) := p_col44(r);
                values_tab(45) := p_col45(r);
                values_tab(46) := p_col46(r);
                values_tab(47) := p_col47(r);
                values_tab(48) := p_col48(r);
                values_tab(49) := p_col49(r);
                values_tab(50) := p_col50(r);
                values_tab(51) := p_col51(r);
                values_tab(52) := p_col52(r);
                values_tab(53) := p_col53(r);
                values_tab(54) := p_col54(r);
                values_tab(55) := p_col55(r);
                values_tab(56) := p_col56(r);
                values_tab(57) := p_col57(r);
                values_tab(58) := p_col58(r);
                values_tab(59) := p_col59(r);
                values_tab(60) := p_col60(r);
                values_tab(61) := p_col61(r);
                values_tab(62) := p_col62(r);
                values_tab(63) := p_col63(r);
                values_tab(64) := p_col64(r);
                values_tab(65) := p_col65(r);
                values_tab(66) := p_col66(r);
                values_tab(67) := p_col67(r);
                values_tab(68) := p_col68(r);
                values_tab(69) := p_col69(r);
                values_tab(70) := p_col70(r);
                values_tab(71) := p_col71(r);
                values_tab(72) := p_col72(r);
                values_tab(73) := p_col73(r);
                values_tab(74) := p_col74(r);
                values_tab(75) := p_col75(r);
                values_tab(76) := p_col76(r);
                values_tab(77) := p_col77(r);
                values_tab(78) := p_col78(r);
                values_tab(79) := p_col79(r);
                values_tab(80) := p_col80(r);
                values_tab(81) := p_col81(r);
                values_tab(82) := p_col82(r);
                values_tab(83) := p_col83(r);
                values_tab(84) := p_col84(r);
                values_tab(85) := p_col85(r);
                values_tab(86) := p_col86(r);
                values_tab(87) := p_col87(r);
                values_tab(88) := p_col88(r);
                values_tab(89) := p_col89(r);
                values_tab(90) := p_col90(r);
                values_tab(91) := p_col91(r);
                values_tab(92) := p_col92(r);
                values_tab(93) := p_col93(r);
                values_tab(94) := p_col94(r);
                values_tab(95) := p_col95(r);
                values_tab(96) := p_col96(r);
                values_tab(97) := p_col97(r);
                values_tab(98) := p_col98(r);
                values_tab(99) := p_col99(r);
                values_tab(100) := p_col100(r);
                values_tab(101) := p_col101(r);
                values_tab(102) := p_col102(r);
                values_tab(103) := p_col103(r);
                values_tab(104) := p_col104(r);
                values_tab(105) := p_col105(r);
                values_tab(106) := p_col106(r);
                values_tab(107) := p_col107(r);
                values_tab(108) := p_col108(r);
                values_tab(109) := p_col109(r);
                values_tab(110) := p_col110(r);
                values_tab(111) := p_col111(r);
                values_tab(112) := p_col112(r);
                values_tab(113) := p_col113(r);
                values_tab(114) := p_col114(r);
                values_tab(115) := p_col115(r);
                values_tab(116) := p_col116(r);
                values_tab(117) := p_col117(r);
                values_tab(118) := p_col118(r);
                values_tab(119) := p_col119(r);
                values_tab(120) := p_col120(r);
                values_tab(121) := p_col121(r);
                values_tab(122) := p_col122(r);
                values_tab(123) := p_col123(r);
                values_tab(124) := p_col124(r);
                values_tab(125) := p_col125(r);
                values_tab(126) := p_col126(r);
                values_tab(127) := p_col127(r);
                values_tab(128) := p_col128(r);
                values_tab(129) := p_col129(r);
                values_tab(130) := p_col130(r);
                values_tab(131) := p_col131(r);
                values_tab(132) := p_col132(r);
                values_tab(133) := p_col133(r);
                values_tab(134) := p_col134(r);
                values_tab(135) := p_col135(r);
                values_tab(136) := p_col136(r);
                values_tab(137) := p_col137(r);
                values_tab(138) := p_col138(r);
                values_tab(139) := p_col139(r);
                values_tab(140) := p_col140(r);
                values_tab(141) := p_col141(r);
                values_tab(142) := p_col142(r);
                values_tab(143) := p_col143(r);
                values_tab(144) := p_col144(r);
                values_tab(145) := p_col145(r);
                values_tab(146) := p_col146(r);
                values_tab(147) := p_col147(r);
                values_tab(148) := p_col148(r);
                values_tab(149) := p_col149(r);
                values_tab(150) := p_col150(r);
                values_tab(151) := p_col151(r);
                values_tab(152) := p_col152(r);
                values_tab(153) := p_col153(r);
                values_tab(154) := p_col154(r);
                values_tab(155) := p_col155(r);
                values_tab(156) := p_col156(r);
                values_tab(157) := p_col157(r);
                values_tab(158) := p_col158(r);
                values_tab(159) := p_col159(r);
                values_tab(160) := p_col160(r);

		-- htp.p('Row:'|| r || ' Calling ob start import row');
                qa_results_interface_pkg.start_import_row(1, orgz_id, hid_planid,
                                script, tailscript, qri_source_code,
                                 qri_source_line_id, po_agent_id);

                 for c in 1..col_count
                 loop
                    flg1 := qa_results_interface_pkg.add_element_value(hid_planid, charid_tab(c),
                                                    values_tab(c), script, tailscript);

                    if (flg1 = 2) then
			l_prompt := qa_ss_core.get_char_prompt(charid_tab(c));
                        fnd_message.set_name('QA', 'QA_SS_INVALID_NUM');
                        fnd_message.set_token('ROWNUMBER', r);
                        fnd_message.set_token('COLNUMBER', c);
			fnd_message.set_token('ELEMENT', l_prompt);
                        -- icx_util.add_error(fnd_message.get);
                        htp.p('<STRONG><FONT COLOR="#FF0000">'||fnd_message.get||'</FONT></STRONG>');
                        htp.nl;
                        No_problem := FALSE; -- this means, there is some error
                    elsif (flg1 = 3) then
			l_prompt := qa_ss_core.get_char_prompt(charid_tab(c));
                        fnd_message.set_name('QA', 'QA_SS_INVALID_DATE');
                        fnd_message.set_token('ROWNUMBER', r);
                        fnd_message.set_token('COLNUMBER', c);
			fnd_message.set_token('ELEMENT', l_prompt);
                        -- icx_util.add_error(fnd_message.get);
                         htp.p('<STRONG><FONT COLOR="#FF0000">'||fnd_message.get||'</FONT></STRONG>');
                         htp.nl;
                        No_problem := FALSE; -- this means, there is some error
                    elsif (flg1 = 4) then
                      -- Adding if statement, Sep 13, 1999 -- talked to mmpatel
                      -- accept null context elems even if they r mandatory BUG 998445
                            if (NOT CxE(charid_tab(c), txn_num)) -- if not a ctx elem, then process
                             then
              			       l_prompt := qa_ss_core.get_char_prompt(charid_tab(c));
                                fnd_message.set_name('QA', 'QA_SS_MAND_VALUE');
                                fnd_message.set_token('ROWNUMBER', r);
                               fnd_message.set_token('COLNUMBER', c);
			                   fnd_message.set_token('ELEMENT', l_prompt);
                               -- icx_util.add_error(fnd_message.get);
                                htp.p('<STRONG><FONT COLOR="#FF0000">'||fnd_message.get||'</FONT></STRONG>');
                                htp.nl;
                                No_problem := FALSE; -- this means, there is some error
                             end if;
                    elsif (flg1 = 1) then
			l_prompt := qa_ss_core.get_char_prompt(charid_tab(c));
                        fnd_message.set_name('QA', 'QA_SS_GENERIC_INVALID');
                        fnd_message.set_token('ROWNUMBER', r);
                        fnd_message.set_token('COLNUMBER', c);
			fnd_message.set_token('ELEMENT', l_prompt);
                        -- icx_util.add_error(fnd_message.get);
                         htp.p('<STRONG><FONT COLOR="#FF0000">'||fnd_message.get||'</FONT></STRONG>');
                         htp.nl;
                        No_problem := FALSE; -- this means, there is some error
                    end if; -- end flg1 check
                 end loop; -- columns loop

                    /* -- Introduced to report values entered for errored rows
                    -- Commented out after aug 11 frz for usability fix
			         if (no_problem = FALSE) then
		    		        htp.p('You entered the following values for this Row: ');
					htp.nl;
				        FOR c in 1..col_count
					LOOP
						htp.p('column '||to_char(c)||' : '|| values_tab(c));
						htp.nl;
					END LOOP;
					htp.nl;
			         else
				           NULL;
			         end if;
                    */
                    -- htp.p('Calling end import row for row : ' || to_char(r)); htp.nl;
                    qa_results_interface_pkg.end_import_row(script, tailscript, No_problem);

                    /* -- commented out after aug 11 frz for usability fix
                    if (no_problem = TRUE) then
		    		        htp.p('Row '||to_char(r) || ': Successfully submitted'); htp.nl;
                            -- Need new fnd seed data july 28, 1999
                            -- Commit done at end of all rows below
			         end if;
                     */
              END IF; -- end check for empty row
        END LOOP; --End Rows Loop

           -- COMMIT; -- commented out after aug 11 frz for usability fix

        If (rows_selected = FALSE) Then
                htp.p(fnd_message.get_string('QA', 'QA_SS_NO_CHANGES')); -- New code
                -- Need new fnd seed data july 28, 1999

        Elsif (No_problem = TRUE) Then
                fnd_message.set_name('QA', 'QA_SS_INSERT_OK');
                htp.p(fnd_message.get);
                Commit; -- there was no problem so we can commit

        Else
            -- icx_admin_sig.error_screen(fnd_message.get);
            -- commented out after aug 11 frz for usability fix
            htp.p(fnd_message.get_string('QA', 'QA_SS_INSERT_NOT_OK'));
            Rollback to start_inserting; -- rollback any inserts issued


         End If; -- end checking value of No_problem
        fnd_message.clear;
        js.ScriptOpen;
            if (No_problem=FALSE) THEN
                 htp.p('javascript:set_clear_var("N")');
            end if;
        js.ScriptClose;
	 htp.p('</BODY>');
	 htp.p('</HTML>');

end if; -- end icx validate session
EXCEPTION
    WHEN orgz_ex THEN
        htp.p('<STRONG><FONT COLOR="#FF0000">Organization Id is Null which raised exception</FONT></STRONG>');

    WHEN plan_ex THEN
        htp.p('<STRONG><FONT COLOR="#FF0000">Plan Id is Null which raised exception</FONT></STRONG>');
    WHEN OTHERS THEN
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END enter_results;
------------------------------------------------------------------------


procedure draw_table(plan_id_i IN qa_plans.plan_id%TYPE DEFAULT NULL,
			txn_num IN NUMBER DEFAULT NULL,
            orgz_id IN NUMBER DEFAULT NULL,
			pk1 IN VARCHAR2 DEFAULT NULL,
			pk2 IN VARCHAR2 DEFAULT NULL,
			pk3 IN VARCHAR2 DEFAULT NULL,
			pk4 IN VARCHAR2 DEFAULT NULL,
			pk5 IN VARCHAR2 DEFAULT NULL,
			pk6 IN VARCHAR2 DEFAULT NULL,
			pk7 IN VARCHAR2 DEFAULT NULL,
			pk8 IN VARCHAR2 DEFAULT NULL,
			pk9 IN VARCHAR2 DEFAULT NULL,
			pk10 IN VARCHAR2 DEFAULT NULL)
IS
 		Ctx qa_ss_const.Ctx_Table;
		 -- Ctx_Table type is declared in pkg spec
        Prompt_Arr qa_ss_const.var30_table;
		lov_arr qa_ss_const.bool_table;
		disp_len_arr qa_ss_const.num_table;
		dv_arr qa_ss_const.var150_table;  -- for Default Value
        charid_array qa_ss_const.num_table;
        names_array qa_ss_const.var30_table;

		no_of_cols NUMBER := 0;
		plan_name_i qa_plans.name%TYPE := NULL;
		l_language_code varchar2(30);
		it_name VARCHAR2(20);
		de_name VARCHAR2(20); -- dependent element name
		Name VARCHAR2(2000);
		char_name_i qa_chars.name%TYPE;
		item_name VARCHAR2(30) := NULL;
        l_Po_Agent_Id NUMBER := NULL;
        l_User_Id NUMBER := NULL;
        l_Item_Id NUMBER := NULL;
        l_Po_Header_Id NUMBER := NULL;
        l_Wip_Entity_Type NUMBER := NULL;
        l_Wip_Rep_Sch_Id NUMBER := NULL;
        l_Po_Release_Id NUMBER := NULL;
        l_Po_Line_Id NUMBER := NULL;
        l_Line_Location_Id NUMBER := NULL;
        l_Po_Distribution_Id NUMBER := NULL;
        l_Wip_Entity_Id NUMBER := NULL;
        l_Wip_Line_Id NUMBER := NULL;
        l_Po_Shipment_Id NUMBER := NULL;
	l_Organization_Id NUMBER := NULL;

        row_color VARCHAR2(20) := 'BLUE';

		-- sql_st VARCHAR2(32000) := NULL; /* Remove this later, only for debug */
		-- iv_string VARCHAR2(30) := NULL; /* remove this too */

		job_pline_ex EXCEPTION;
		flag NUMBER:=0;

		-- Aug 03, 1999 adding data entry hint to this cursor

		dhint_tab qa_ss_const.var150_table;

		CURSOR char_cur IS
		select qpc.prompt_sequence, qc.char_id, qc.name, NVL(qc.developer_name, qc.name) AS cname, qc.sql_validation_string, qpc.prompt, qc.display_length, qpc.default_value,
qpc.enabled_flag, qc.data_entry_hint
		from qa_plan_chars qpc, qa_chars qc
		where qpc.plan_id = plan_id_i
		AND qpc.char_id = qc.char_id
		AND qpc.enabled_flag = 1
		ORDER BY qpc.prompt_sequence;
		-- changed above cursor qpc.prompt, qpc.default_value
		-- to fix bug 1276799
BEGIN
    if (icx_sec.validatesession) then

                fnd_message.clear;

    			Default_In_Values(Ctx, Txn_Num, PK1, PK2, PK3, PK4,
				PK5, PK6, PK7, PK8, PK9, PK10, l_Po_Agent_Id, l_Item_Id, l_Po_Header_Id,
                l_Wip_Entity_Type, l_Wip_Rep_Sch_Id, l_Po_Release_Id, l_Po_Line_Id,
                l_Line_Location_Id, l_Po_Distribution_Id, l_Wip_Entity_Id,
                l_Wip_Line_Id, l_Po_Shipment_Id, l_Organization_Id  );
			-- Remember Ctx is InOut and l_Po_agent_id is Out
            -- The l_po_agent_id is stored in a formhidden below
			-- Also above function will alter some global package variables
			-- Keep in mind it will set global variables starting with G_etc.


		l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
        l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);

		 Name := owa_util.get_cgi_env('SCRIPT_NAME');

        select qp.name into plan_name_i
 		from qa_plans qp
		where qp.plan_id = plan_id_i;

		-- htp.p('Debug: Job = ' || job_i);


		htp.p('<HTML>');
		htp.p('<HEAD>');
        htp.linkRel('STYLESHEET', '/OA_HTML/'||
				l_language_code||'/POSSTYLE.css');

        generate_eqr_javascript;  -- this is a pl/sql procedure call. procedure is in this pkg

		 htp.p('<BODY bgcolor="#cccccc" onLoad="javascript:parent.clear_if_needed()">');
        -- htp.p('<BODY bgcolor="#cccccc" onLoad="if (parent.buttonsFrame.document.buttonHiddenF.clear_var.value = ''N'') {parent.clr_form()}">');
         -- htp.p('<BODY bgcolor="#cccccc" onLoad="x=parent.buttonsFrame.document.buttonHiddenF.clear_var.value; alert(x)">');
        -- icx_admin_sig.toolbar(language_code => c_language_code, disp_help => 'N');

     fnd_message.set_name('QA', 'QA_SS_EQR');
     /*
     icx_plug_utilities.toolbar(substr(fnd_message.get,1,40), p_language_code=>l_language_code,
                    p_disp_help=>'Y',p_disp_exit=>'Y');
	 icx_plug_utilities.plugbanner(plan_name_i);
    */
		-- htp.p('Org id is ' || fnd_profile.value('ORG_ID') );
		-- htp.p('User id is ' || fnd_profile.value('USER_ID') );
	-- htp.p('pvwebuserid: ' || icx_sec.getID(icx_sec.PV_WEB_USER_ID));

		 --hidden_elems; -- CALL TO HIDDEN_ELEMS to set hidden fields
            htp.p('<FORM ACTION="" NAME="HiddenRSMDF" METHOD="">');
            htp.formHidden('x_txn_num', txn_num);
            htp.formHidden('x_wip_entity_type', l_wip_entity_type);
            htp.formHidden('x_wip_rep_sch_id', l_wip_rep_sch_id);
            htp.formHidden('x_po_header_id', l_po_header_id);
            htp.formHidden('x_po_release_id', l_po_release_id);
            htp.formHidden('x_po_line_id', l_po_line_id);
            htp.formHidden('x_line_location_id', l_line_location_id);
            htp.formHidden('x_po_distribution_id', l_po_distribution_id);
            htp.formHidden('x_item_id', l_item_id);
            htp.formHidden('x_wip_entity_id', l_wip_entity_id);
            htp.formHidden('x_wip_line_id', l_wip_line_id);
            htp.formHidden('x_po_shipment_id', l_po_shipment_id);
            htp.p('</FORM>');

            htp.p('<FORM ACTION="qa_ss_core.call_workflow" NAME="WORKFLOWDOC" METHOD="POST">');
            htp.formHidden('x_buyer_id', l_po_agent_id);
            htp.formHidden('x_source_id', l_user_id);
            htp.formHidden('x_plan_id', plan_id_i);
            htp.formHidden('x_item_id', l_Item_Id);
            htp.formHidden('x_po_header_id', l_po_header_id);
            htp.p('</FORM>');

     		 htp.p('<FORM ACTION="qa_ss_core.enter_results" NAME="RSMDF" METHOD="POST">');
			-- htp.formHidden('No_Dependency','No_Dependency'); --This is no longer needed

		htp.tableOpen(cborder=>'BORDER=2',calign=>'CENTER', cattributes=>'CELLPADDING=2 cellspacing=1');

		-- htp.p('Language Code = ' || l_language_code);
		-- htp.br;

		-- htp.tableCaption(htf.bold(plan_name_i));
		-- htp.tableRowOpen(cattributes => 'BGCOLOR="#336699"');
        htp.tableRowOpen;
		  -- htp.p('Got here 1');

              htp.tableData(cvalue=>'<font class=promptwhite>'||'Select'||'</font>',
						calign=>'LEFT', cattributes=>'valign=bottom bgcolor="#336699"');

		    FOR char_rec IN char_cur
		    LOOP
			 -- htp.p(' Got here 2');
				no_of_cols := no_of_cols + 1;


			-- htp.p('enable_arr('||no_of_cols||') = ' || enable_arr(no_of_cols));

				IF (is_lov_needed(char_rec.char_id, Txn_Num) = FALSE)
				then
				  -- if no lov is needed or if ctxt elmt
					htp.tableData(cvalue=>'<font class=promptwhite>'||char_rec.prompt||'</font>',
						calign=>'LEFT', cattributes=>'valign=bottom bgcolor="#336699"');
					lov_arr(no_of_cols) := FALSE;
							 --span one column
				ELSE --span 2 cols
					htp.tableData(cvalue=>'<font class=promptwhite>'||char_rec.prompt||'</font>',
						calign=>'LEFT',
						ccolspan=>'2', cattributes=>'valign=bottom bgcolor="#336699"' );
					lov_arr(no_of_cols) := TRUE;
					-- this is an lov field
				END IF;
			dv_arr(no_of_cols) := char_rec.default_value;
			disp_len_arr(no_of_cols) := char_rec.display_length;
			Prompt_Arr(no_of_cols) := char_rec.prompt; --needed to draw end of table
			names_array(no_of_cols) := char_rec.cname;
			charid_array(no_of_cols) := char_rec.char_id;
			IF (char_rec.data_entry_hint IS NOT NULL) Then
			dhint_tab(no_of_cols) :=
				ICX_UTIL.replace_onMouseOver_quotes(
					SUBSTRB(char_rec.data_entry_hint,1,90));
			ELSE
			dhint_tab(no_of_cols) := NULL;
			END IF; -- end if for data entry hint

			-- htp.p('column'||no_of_cols||' :  char_name= '||char_rec.name);
		    END LOOP;
		   -- htp.p('Got here 3');

		htp.tableRowClose;
			-- Below Line for UI Standards
			htp.p('<TR></TR><TR></TR>'); -- DO NOT COMMENT THIS UI Standard

		  -- htp.p('Got here 4'); htp.nl;
          -- htp.p('Number of cols = ' || no_of_cols); htp.nl;
		FOR rows IN 1..qa_ss_const.no_of_rows
		LOOP
            if (row_color = 'BLUE') THEN
        		htp.tableRowOpen(cattributes => 'BGCOLOR="#99CCFF"');
                row_color := 'WHITE';
            else
                htp.tableRowOpen(cattributes => 'BGCOLOR="#FFFFFF"');
                row_color := 'BLUE';
            end if; -- end if for row_color
            -- New code line for field below. Indicates if a row was modified
            -- Dont make this a table data hiddenfield <TD> It screws up the UI
            -- Consequently htp used, NOT htf
            -- htp.formHidden('selectbox', cvalue=>'N') ;
            htp.tableData( htf.formCheckbox(cname=>'selectbox',
                                            cvalue=>to_char(rows)));


			FOR cols IN 1..no_of_cols
			LOOP
			   -- htp.p('Got here 5');
               -- htp.p('col = ' || cols); htp.nl;
			  item_name := 'p_col' || TO_CHAR(cols);
                    -- htp.p('charid= ' || charid_array(cols) || '  txnnum= ' || Txn_Num);
			  IF ( CxE(charid_array(cols), Txn_Num) ) Then
                    -- this is a context element for this txn
                    -- so create a textual data and corresponding hidden field value

                        -- htp.p('Is a context element'); htp.nl;
				htp.tableData( NVL(Ctx(charid_array(cols)), '&nbsp'), calign=>'LEFT',
                                crowspan=>'1',
                                cattributes=>'VALIGN="CENTER"');
                htp.formHidden(item_name, Ctx(charid_array(cols)));

			   else -- Not a default context element
                        -- htp.p('Not context element'); htp.nl;
                        -- New code, the whole onchange piece is new july28,1999
			-- Onfocus added on Aug 03, 1999

                /*
			  	htp.tableData(htf.formText(item_name,disp_len_arr(cols),150,
							dv_arr(cols),'onChange="document.RSMDF.selectbox['
                                    || to_char(rows-1) || '].value=''Y''"  onFocus="window.status='''||dhint_tab(cols)||'''"' ),
                             calign=>'CENTER',
							crowspan=>'1',
							cattributes=>'VALIGN="CENTER"');
                */
                -- Above commented out on Aug 13, 1999 to try the below checkbox instead of hidden field
                -- changing .value=''Y''  to  .checked=true
                htp.tableData(htf.formText(item_name,disp_len_arr(cols),150,
							dv_arr(cols),'onChange="document.RSMDF.selectbox['
                                    || to_char(rows-1) || '].checked=true"  onFocus="window.status='''||dhint_tab(cols)||'''"' ),
                             calign=>'CENTER',
							crowspan=>'1',
							cattributes=>'VALIGN="CENTER"');

			      IF (lov_arr(cols)) THEN
				it_name := 'p_col' ||to_char(cols)||'['||to_char(rows-1) || ']';

				-- FNDILOV.gif is older   FNDLSTOV.gif is newer
				htp.p('<TD><A HREF="javascript:LOV(' || To_Char(rows-1) || ','
				   || charid_array(cols) || ', '||cols || ', '|| 'document.RSMDF.'
					||it_name || ' )">
				  <img src="/OA_MEDIA/FNDILOV.gif" ALIGN="CENTER" ALT="Lov"
					 BORDER=0 WIDTH=23 HEIGHT=21></A></TD>');
				-- Use rows-1 for javascript rows are from Zero unlike plsql
			      END IF; --end if lov icon needed or not
			  END IF; -- end whether context elemnt or not


			item_name := NULL;

			 -- htp.p('Got here 8'); htp.nl;

			END LOOP; -- end col loop
		 	 -- htp.p('got here 9');

			-- Hidden columns
			FOR cols IN no_of_cols+1..qa_ss_const.max_cols
			LOOP
				-- htp.p('got here 10');
			  item_name := 'p_col' || TO_CHAR(cols);
			  htp.formHidden(item_name);
			  item_name := NULL;
			END LOOP; -- end hidden column loop


		htp.tableRowClose;
			-- htp.p('got here 11'||htf.br);
		END LOOP; /* end rows loop */
		 -- htp.p('got here 12');

         /* -- commenting out becos no longer need bottom table header acc to new UI
		htp.p('<TR></TR><TR></TR>');
		htp.tableRowOpen(cattributes => 'BGCOLOR="#83C1C1"');
		FOR i in 1..no_of_cols
		LOOP
			-- htp.p('got here 13');

			IF ( lov_arr(i) = FALSE)
			then
				htp.tableHeader(cvalue=>Prompt_Arr(i),
						calign=>'CENTER');
            else
				htp.tableHeader(cvalue=>Prompt_Arr(i),
						calign=>'CENTER',
						ccolspan=>'2');
			END IF;
		END LOOP;
            -- where is tablerowclose? is this omitted by mistake?
        */
			-- htp.p('got here 14');
		htp.tableClose;
		htp.formHidden('hid_planid', plan_id_i);
        htp.formHidden('orgz_id', orgz_id);
        htp.formHidden('txn_num', Txn_Num);
        htp.formHidden('po_agent_id', l_Po_Agent_Id);
        -- Just like ur having the above hiddenfield  for planid
        -- have a couple of hidden fields called orgz_id and txn_num
        -- so they can also be passed to the enter_results procedure
            htp.formHidden('x_source_id', l_user_id);
            htp.formHidden('x_item_id', l_Item_Id);
            htp.formHidden('x_po_header_id', l_po_header_id);
	-- The above hidden fields added for BUG 998381
	-- so they are part of RSMDF in addition to WORKFLOWDOC
	      -- htp.formSubmit(NULL, 'Enter Results');

		 htp.br;

      	htp.p('</FORM>');

	htp.p('</BODY>');
	htp.p('</HTML>');


    end if; -- end icx validatesession

EXCEPTION
    WHEN job_pline_ex THEN
			htp.p('Job and Production Line Exception thrown in draw_table');

    WHEN OTHERS THEN
        htp.p('Exception in procedure draw_table');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
  END draw_table;
------------------------------------------------------------------------------------

 function CxE(cid IN Number, txnumber IN NUMBER DEFAULT NULL)
		 RETURN BOOLEAN

 IS
     coll_trigg NUMBER;
     coll_seed_ex EXCEPTION;
 BEGIN

    Select count(1) INTO coll_trigg
    From qa_txn_collection_triggers qtct
    WHERE qtct.transaction_number = txnumber
    AND qtct.collection_trigger_id = cid;

    IF (coll_trigg = 1) Then
        RETURN TRUE; -- it is a context element for this txn
    Elsif (coll_trigg = 0) THEN
        RETURN FALSE; -- not a context element for this txn
    Else
        Raise coll_seed_ex; -- seed data problem in coll. triggers
    END IF; -- endif for coll_trigg comparison

 EXCEPTION
    WHEN coll_seed_ex THEN
        htp.p('Exception in function CxE - Collection Trigger');
    WHEN OTHERS THEN
        htp.p('Exception in function CxE');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
 END CxE;
--------------------------------------------------------------------------------------


 function is_lov_needed(cid IN Number,
                        Txn_Num IN NUMBER DEFAULT NULL)
		RETURN BOOLEAN

 IS
 	cx Boolean;
	inlist_exists NUMBER:=0;
	sql_val_st VARCHAR2(3000) := NULL;

BEGIN
if (CxE(cid, Txn_Num)) then
 		return FALSE;
	end if;
    -- If it is a context element for the given txn, then we
    -- return above. Below stmts are not executed

	SELECT values_exist_flag, sql_validation_string INTO inlist_exists,sql_val_st
	FROM qa_chars
	WHERE char_id = cid;

	if (inlist_exists = 1) then
		return TRUE;
	end if;
	if (sql_val_st IS NOT NULL) then
		return TRUE;
	end if;

    -- Hardcoded collection elements are taken care of below
     -- if hardcoded lov record group is available in regular
        -- Quality Application in QRES block of QLTRSMDF form
	if (cid IN (qa_ss_const.Item,
                qa_ss_const.Locator,
                qa_ss_const.Comp_Revision,
                qa_ss_const.Comp_Subinventory,
                qa_ss_const.Comp_UOM,
                qa_ss_const.Customer_Name,
                qa_ss_const.Department,
                qa_ss_const.From_Op_Seq_Num,
                qa_ss_const.Production_Line,
                qa_ss_const.PO_Number,
                qa_ss_const.PO_Release_Num,
                qa_ss_const.PO_Shipment_Num,
                qa_ss_const.Project_Number,
                qa_ss_const.Receipt_Num,
                qa_ss_const.Resource_Code,
                qa_ss_const.Revision,
                qa_ss_const.RMA_Number,
                qa_ss_const.Sales_Order,
                qa_ss_const.Subinventory,
                qa_ss_const.Task_Number,
                qa_ss_const.To_Department,
                qa_ss_const.To_Op_Seq_Num,
                qa_ss_const.UOM,
                qa_ss_const.Vendor_Name,
                qa_ss_const.Job_Name)
        )

	then
		return TRUE;
	else
		return FALSE;
	end if;

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in function is_lov_needed');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END is_lov_needed;

------------------------------------------------------------------------------------------

 procedure draw_frames(plan_id_i IN qa_plans.plan_id%TYPE DEFAULT NULL,
			txn_num IN NUMBER DEFAULT NULL,
			orgz_id IN NUMBER DEFAULT NULL,
			pk1 IN VARCHAR2 DEFAULT NULL,
			pk2 IN VARCHAR2 DEFAULT NULL,
			pk3 IN VARCHAR2 DEFAULT NULL,
			pk4 IN VARCHAR2 DEFAULT NULL,
			pk5 IN VARCHAR2 DEFAULT NULL,
			pk6 IN VARCHAR2 DEFAULT NULL,
			pk7 IN VARCHAR2 DEFAULT NULL,
			pk8 IN VARCHAR2 DEFAULT NULL,
			pk9 IN VARCHAR2 DEFAULT NULL,
			pk10 IN VARCHAR2 DEFAULT NULL)

IS
    xyz varchar2(20000);
    -- In this code, xyz is used for a URL string construction
    toolbar_heading VARCHAR2(500);
    l_plan_name VARCHAR2(50);
    l_language_code VARCHAR2(30);

    CURSOR plan_name_cur IS
	SELECT name
	FROM QA_PLANS
	WHERE plan_id = plan_id_i ;

BEGIN
    if (icx_sec.validatesession) then
	l_language_code := icx_sec.getid(icx_sec.PV_LANGUAGE_CODE);

	OPEN plan_name_cur;
	FETCH plan_name_cur INTO l_plan_name;
	CLOSE plan_name_cur;

    xyz := 'qa_ss_core.draw_table?plan_id_i=' || plan_id_i
                                               || '&' || 'txn_num=' || Txn_Num
                                               || '&' || 'orgz_id=' || orgz_id
                                               || '&' || 'pk1=' || pk1
                                               || '&' || 'pk2=' || pk2
                                               || '&' || 'pk3=' || pk3
                                               || '&' || 'pk4=' || pk4
                                               || '&' || 'pk5=' || pk5
                                               || '&' || 'pk6=' || pk6
                                               || '&' || 'pk7=' || pk7
                                               || '&' || 'pk8=' || pk8
                                               || '&' || 'pk9=' || pk9
                                               || '&' || 'pk10=' || pk10;
	htp.p('<HTML>');
	htp.p('<HEAD>');
    htp.p('<LINK REL="STYLESHEET" HREF="/OA_HTML/'
			||l_language_code||'/POSSTYLE.css">');


        htp.p('<script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
        htp.p('</script>');
        htp.p('<script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
        htp.p('</script>');
        htp.p('<script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
        htp.p('</script>');

        js.scriptOpen;
        pos_global_vars_sv.InitializeMessageArray;
        js.scriptClose;

	htp.p('<SCRIPT LANGUAGE="JavaScript">');
	htp.p('function eqr_submit()
		{
			eqrFrame.document.RSMDF.submit();

		}');
	htp.p('function clr_form()
		{
			eqrFrame.document.RSMDF.reset();
		}');
	htp.p('function go_bk()
		{
			eqrFrame.history.go(-1);
		}');

    -- New code trial below
    htp.p('function notify_buyer(buyer_msg)
		{
			if (confirm(buyer_msg))
                {
                   // buttonsFrame.location = "http://www.oracle.com";
                    eqrFrame.document.WORKFLOWDOC.submit();
                }
		}');

        -- Newly added below after Aug 11 frz for usability fix
        htp.p('function clear_if_needed()
                {
                    if (buttonsFrame.document.buttonHiddenF.clear_var.value == "Y")
                        {
                        clr_form();
                        }
                     else
                        {
                         buttonsFrame.document.buttonHiddenF.clear_var.value = "Y" ;
                        // reset the value so as to submit again
                        }
                 }');

	htp.p('</SCRIPT>');
	htp.p('</HEAD>');
    -- NEW  made the border=0 in the frameset. This prevents accidental reloading
    -- when frame is resized. Now that can be prevented
     htp.p('<frameset rows="50,*,40" border=0>');

	toolbar_heading := fnd_message.get_string('QA', 'QA_SS_EQR');
	toolbar_heading := wfa_html.conv_special_url_chars(toolbar_heading);
        htp.p('<frame src="pos_toolbar_sv.PaintToolbar?p_title='||toolbar_heading||'"
                name=toolbar
                marginwidth=6
                marginheight=2
                scrolling=no>');
        htp.p('<frameset cols="3,*,3" border=0>');
        htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
                name=borderLeft
                marginwidth=0
                marginheight=0
                scrolling=no>');

	l_plan_name := wfa_html.conv_special_url_chars(l_plan_name);
        htp.p('<frameset rows="30,*,5" border=0>');
        htp.p('<frame src="pos_upper_banner_sv.PaintUpperBanner?p_product=QA'||'&'||'p_title='
		|| l_plan_name || '"
                name=upperbanner
                marginwidth=0
                marginheight=0
                scrolling=no>');


	htp.p('<FRAME NAME="eqrFrame" SRC="' || xyz || '">');

     htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSLWBAN.htm"
                name=lowerbanner
                marginwidth=0
                marginheight=0
                scrolling=no>');

         htp.p('</frameset>');
         htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
                name=borderRight
                marginwidth=0
                marginheight=0
                scrolling=no>');
         htp.p('</frameset>');
         htp.p('<frame src="qa_ss_core.qlt_buttons"
                name=buttonsFrame
                marginwidth=0
                marginheight=0
                scrolling=no>');


	htp.p('</FRAMESET>');
	htp.p('</HTML>');

    end if; -- end icx session
EXCEPTION
     WHEN OTHERS THEN
	IF plan_name_cur%ISOPEN THEN
		CLOSE plan_name_cur;
	END IF;
        htp.p('Exception in procedure draw_frames');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END draw_frames;
-------------------------------------------------------------------------------

procedure qlt_buttons

IS

l_language_code varchar2(30);
msg varchar2(2000);
l_profile_val NUMBER;

BEGIN
    if (icx_sec.validatesession) then
            l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
            if (l_language_code is Null) then
                l_language_code := 'US';
            end if;

            fnd_message.clear;
            fnd_message.set_name('QA','QA_SS_SUBMIT_DATA');
            msg  := fnd_message.get;
            msg := substr(msg, 1, 20);

	    l_profile_val := FND_PROFILE.VALUE('QA_SS_RECEIVE_NOTIFICATIONS');
	   -- htp.p('l_profile_val = ' || l_profile_val); htp.nl;

        htp.p('<HTML>');
        htp.p('<BODY bgcolor=#336699>');

        htp.p('<FORM NAME="buttonHiddenF" ACTION="" METHOD="POST">');
        htp.formHidden('clear_var', 'Y');
        htp.p('</FORM>');

        /*
        icx_util.DynamicButton(P_ButtonText => msg,
                       	P_ImageFileName => 'FNDBSBMT',
                       	P_OnMouseOverText => msg,
                       	P_HyperTextCall => 'javascript:parent.eqr_submit()',
                       	P_LanguageCode => l_language_code,
                        P_JavaScriptFlag => FALSE);
        */
        htp.p('<TABLE WIDTH=60% CELLPADDING=0 CELLSPACING=0 BORDER=0>');
	   htp.p('<TR>');
	   htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100>');

	   qa_ss_core.draw_html_button('javascript:parent.eqr_submit()', msg);

            fnd_message.set_name('QA', 'QA_SS_CLEAR_FORM');
            msg := fnd_message.get;
            msg := substr(msg, 1, 20);
            /*
            icx_util.DynamicButton(P_ButtonText => msg,
                       	P_ImageFileName => 'FNDBCLR',
                       	P_OnMouseOverText => msg,
                       	P_HyperTextCall => 'javascript:parent.clr_form()',
                       	P_LanguageCode => l_language_code,
                        P_JavaScriptFlag => FALSE);
            */
           htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100>');
		  qa_ss_core.draw_html_button('javascript:parent.clr_form()', msg);
	       htp.p('</TD>');

            fnd_message.clear;

            -- New code trial below
            msg := fnd_message.get_string('QA', 'QA_SS_NOTIFY_DIALOG');
            msg := substr(msg, 1, 180);

            /*
            icx_util.DynamicButton(P_ButtonText=>substr(fnd_message.get_string('QA','QA_SS_NOTIFY'),1,23),
                                    P_ImageFileName => 'FNDBSBMT',
                                    P_OnMouseOverText => 'Notify Buyer',
                                    P_HyperTextCall => 'javascript:parent.notify_buyer('''||msg||''')',
                                    P_LanguageCode => l_language_code,
                                    P_JavaScriptFlag => FALSE);
            */
	IF ( (l_profile_val = 1) OR (l_profile_val IS NULL) ) THEN
        	    htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100>');
			qa_ss_core.draw_html_button('javascript:parent.notify_buyer('''||msg||''')',
                        substr(fnd_message.get_string('QA','QA_SS_NOTIFY'),1,23) );
    		     htp.p('</TD>');
	END IF; -- end check for l_profile_val

	   htp.p('</TR>');
	   htp.p('</TABLE>');


            htp.p('</BODY>');
            htp.p('</HTML>');

    end if; -- end icx session

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure qlt_buttons');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END qlt_buttons;
---------------------------------------------------------------------------------

procedure Default_In_Values (Ctx IN OUT NOCOPY qa_ss_const.Ctx_Table,
			Txn_Num IN NUMBER DEFAULT NULL,
			PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL,
            X_Po_Agent_Id OUT NOCOPY NUMBER,
            X_Item_Id OUT NOCOPY NUMBER,
            X_Po_Header_Id OUT NOCOPY NUMBER,
            X_Wip_Entity_Type OUT NOCOPY NUMBER,
            X_Wip_Rep_Sch_Id OUT NOCOPY NUMBER,
            X_Po_Release_Id OUT NOCOPY NUMBER,
            X_Po_Line_Id OUT NOCOPY NUMBER,
            X_Line_Location_Id OUT NOCOPY NUMBER,
            X_Po_Distribution_Id OUT NOCOPY NUMBER,
            X_Wip_Entity_Id OUT NOCOPY NUMBER,
            X_Wip_Line_Id OUT NOCOPY NUMBER,
            X_Po_Shipment_Id OUT NOCOPY NUMBER,
	    X_Organization_Id OUT NOCOPY NUMBER
)

 IS
 	not_selfserve EXCEPTION;
 BEGIN

	If (Txn_Num = 100) Then -- OSP Txn
            qa_ss_osp.default_osp_values(Ctx, Txn_Num, PK1, PK2, PK3,
                        PK4, PK5, PK6, PK7, PK8, PK9, PK10, X_Po_Agent_Id,
                        X_Item_Id, X_Po_Header_Id, X_Wip_Entity_Type,
                        X_Wip_Rep_Sch_Id, X_Po_Release_Id, X_Po_Line_Id,
                        X_Line_Location_Id, X_Po_Distribution_Id, X_Wip_Entity_Id,
                        X_Wip_Line_Id, X_Po_Shipment_Id, X_Organization_Id);
    Elsif (Txn_Num = 110) Then -- Shipments Txn
            qa_ss_ship.default_ship_values(Ctx, Txn_Num, PK1, PK2, PK3,
                        PK4, PK5, PK6, PK7, PK8, PK9, PK10, X_Po_Agent_Id,
                         X_Item_Id, X_Po_Header_Id,
                         X_Wip_Entity_Type, X_Wip_Rep_Sch_Id,
                         X_Po_Release_Id, X_Po_Line_Id,
                         X_Line_Location_Id, X_Po_Distribution_Id,
                         X_Wip_Entity_Id, X_Wip_Line_Id, X_Po_Shipment_Id,
			 X_Organization_Id);
    ELSE
		Raise not_selfserve;

	END IF; -- end if osp txn



EXCEPTION
    WHEN not_selfserve Then
        htp.p('Exception in procedure Default_In_Values');
		htp.p('This is NOT A self-service Transaction! Alert!!!');
    WHEN OTHERS THEN
        htp.p('Exception in procedure Default_In_Values');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

 END Default_In_Values;

------------------------------------------------------------------------------------
--
-- Bug 22176228
-- Stubbing out the API to avoid security issue due to
-- SQL injection through ss_where_clause
-- ntungare
--
procedure VQR(plan_id_i IN qa_plans.plan_id%TYPE,
		start_row IN NUMBER DEFAULT 1,
		end_row IN NUMBER DEFAULT 20,
		ss_where_clause in varchar2 default null)

IS
--	l_language_code varchar2(30);
--	num_of_col NUMBER;
--	vname VARCHAR2(30) := NULL;
--	dyn_cur INTEGER;
--	ignore INTEGER;
--	tempstr VARCHAR2(150);
--	ind NUMBER := 0;
--    msg VARCHAR2(2000);
--
--	Prompt_Arr qa_ss_const.var30_table;
--
--	charname qa_ss_const.var30_table;
--
--	charid qa_ss_const.num_table;
--	sql_st VARCHAR2(32000) := NULL;
--	plan_name_i qa_plans.name%TYPE := NULL;
--
--    row_color VARCHAR2(10) := 'BLUE';
--
--	l_query_size NUMBER := 20;
--	r_cnt NUMBER;
--	srow_st varchar2(1000);
--	erow_st varchar2(1000);
--	more_records BOOLEAN;
--	ss_w_c varchar2(5000) := NULL;
--
--	CURSOR char_cur IS
--	select qpc.prompt_sequence, qc.char_id, qc.name, qc.prompt, qpc.enabled_flag
--	from qa_plan_chars qpc, qa_chars qc
--	where qpc.plan_id = plan_id_i
--	AND qpc.char_id = qc.char_id
--	AND qpc.enabled_flag = 1
--	ORDER BY qpc.prompt_sequence;

BEGIN
--    -- htp.p('vqr procedure entered');
--   if (icx_sec.validatesession) then
--
--    fnd_message.clear;
--    l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--
--
--	-- htp.p('after lang code: ' || l_language_code);
--	-- htp.p('ss_where='||ss_where_clause); htp.nl;
--	if (ss_where_clause is not null) then
--		ss_w_c := wfa_html.conv_special_url_chars(ss_where_clause);
--	end if;
--	num_of_col := 0;
--
--	select qp.name into plan_name_i
--	from qa_plans qp
--	where qp.plan_id = plan_id_i;
--
--	 vname := 'Q_' || replace(substr(plan_name_i,1,25),' ','_') || '_V';
--	 vname := UPPER(vname);
--
--	htp.p('<HTML>');
--	htp.p('<HEAD>');
--	htp.p('</HEAD>');
--	htp.p('<BODY bgcolor="#cccccc">');
--
--    fnd_message.set_name('QA', 'QA_SS_VQR');
--    msg := fnd_message.get;
--    msg := substr(msg, 1, 40);
--    /*
-- 	icx_plug_utilities.toolbar(msg, p_language_code=>l_language_code,
--                    p_disp_help=>'Y',p_disp_exit=>'Y');
--	icx_plug_utilities.plugbanner(plan_name_i);
--    */
--
--	htp.p('Records ' || to_char(start_row) || ' to ' || to_char(end_row));
--
--	htp.tableOpen(calign=>'CENTER', cborder=>'BORDER=2', cattributes=>'CELLPADDING=2');
--	htp.tableRowOpen(cattributes=>'BGCOLOR="#336699"');
--
--	-- htp.p('Before cursor loop.  msg = '||msg);
--
--
--	FOR char_rec IN char_cur
--	LOOP
--		num_of_col := num_of_col + 1;
--		htp.tableHeader(cvalue=>'<font color=#ffffff>'||char_rec.prompt||'</font>', calign=>'CENTER');
--		Prompt_Arr(num_of_col) := char_rec.prompt;
--		charname(num_of_col) := replace(UPPER(char_rec.name),' ','_');
--		charid(num_of_col) := char_rec.char_id;
--	END LOOP; -- end char_rec loop
--	-- htp.p('after cur loop');
--
--		htp.tableHeader(cvalue=>'<font color=#ffffff>'||fnd_message.get_string('QA','QA_SS_CREATED_BY')||'</font>', calign=>'CENTER');
--		htp.tableHeader(cvalue=>'<font color=#ffffff>'||fnd_message.get_string('QA','QA_SS_COLLECTION')||'</font>', calign=>'CENTER');
--		htp.tableHeader(cvalue=>'<font color=#ffffff>'||fnd_message.get_string('QA','QA_SS_ENTRY_DATE')||'</font>', calign=>'CENTER');
--	htp.tableRowClose;
--	htp.p('<TR></TR><TR></TR>'); -- This is for UI Standard
--
--		-- htp.p('Before call to build vqr sql');
--
--
--        -- Call OB's pkg
--       sql_st := qa_results_interface_pkg.BUILD_VQR_SQL(plan_id_i,
--						 ss_where_clause);
--	--   htp.p('Sql stmt returned is: ' || sql_st);
--
--
--	dyn_cur := dbms_sql.open_cursor;
--	dbms_sql.parse(dyn_cur, sql_st, dbms_sql.v7);
--
--	FOR i IN 1..num_of_col+3  -- +3 is for createdby,collectionid and entry date
--				  -- standard columns
--	Loop
--		Dbms_sql.define_column(dyn_cur, i, tempstr, 150);
--	End Loop; --end for loop for define columns
--
--	ignore := dbms_sql.execute(dyn_cur);
--
--	r_cnt := 0;
--	more_records := TRUE;
--	LOOP
--	If dbms_sql.fetch_rows(dyn_cur) > 0 Then
--		r_cnt := r_cnt+1;
--		if (r_cnt > end_row) then
--			exit;
--		end if;
--
--	  if (r_cnt >= start_row) then
--            if (row_color = 'BLUE') Then
--	           htp.tableRowOpen(cattributes=>'BGCOLOR="#99ccff"');
--               row_color := 'WHITE';
--            else
--                htp.tableRowOpen(cattributes=>'BGCOLOR="#ffffff"');
--               row_color := 'BLUE';
--            end if; -- end if for row_color
--	  FOR i IN 1..num_of_col+3
--	  Loop
--		Dbms_Sql.column_value(dyn_cur, i, tempstr);
--		htp.tableData(NVL(tempstr, '&nbsp'));
--	  End Loop; -- End for loop inside of dyn cursor loop
--	  htp.tableRowClose;
--
--	  end if; -- end r_cnt check
--	ELSE
--		-- no more row to process
--
--		more_records := FALSE;
--		Exit;
--	END IF; -- if fetch rows
--
--	END LOOP;
--
--    /* -- commenting out becos bottom table header not part of new UI
--	htp.p('<TR></TR><TR></TR>');
--	htp.tableRowOpen(cattributes=>'BGCOLOR="#83C1C1"');
--	FOR i IN 1..num_of_col
--	LOOP
--		htp.tableHeader(cvalue=>Prompt_Arr(i), calign=>'CENTER');
--	END LOOP;
--		htp.tableHeader(cvalue=>'Created By', calign=>'CENTER');
--		htp.tableHeader(cvalue=>'Collection', calign=>'CENTER');
--		htp.tableHeader(cvalue=>'Entry Date', calign=>'CENTER');
--	htp.tableRowClose;
--    */
--
--	htp.tableClose;
--
--	srow_st := 'qa_ss_core.VQR?plan_id_i='|| plan_id_i
--		   || '&' || 'start_row=' || to_char(start_row-l_query_size)
--		   || '&' || 'end_row=' || to_char(start_row-1)
--		   || '&' || 'ss_where_clause=' || ss_w_c;
--
--
--	erow_st := 'qa_ss_core.VQR?plan_id_i='|| plan_id_i
--		   || '&' || 'start_row=' || to_char(end_row+1)
--		   || '&' || 'end_row=' || to_char(end_row+l_query_size)
--		   || '&' || 'ss_where_clause=' || ss_w_c;
--
--
--
--	if (start_row > 1) then
--	htp.anchor(srow_st, fnd_message.get_string('QA','QA_SS_PREVIOUS'));
--	end if;
--
--	htp.p('  --------  ');
--
--	if (more_records = TRUE) then
--	htp.anchor(erow_st, fnd_message.get_string('QA','QA_SS_NEXT'));
--	end if;
--
--	htp.p('</BODY>');
--	htp.p('</HTML>');
--
--	DBMS_SQL.Close_Cursor(dyn_cur);
--
--
--
-- end if; -- end icx session

   NULL;
--EXCEPTION
--    WHEN OTHERS THEN
--        IF DBMS_SQL.IS_OPEN(dyn_cur) Then
--		  DBMS_SQL.CLOSE_CURSOR(dyn_cur);
--	  END IF;
--      Raise;
--        htp.p('Exception in procedure VQR');
--        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

END VQR;
-------------------------------------------------------------------------------------

procedure draw_display_field ( disp_text IN VARCHAR2 )
IS

BEGIN
    NULL;

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure draw_display_field');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

END draw_display_field;
---------------------------------------------------------------

procedure draw_input_field (itemname IN VARCHAR2, def_value IN VARCHAR2, size_i IN VARCHAR2 )
IS

BEGIN

    NULL;

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure draw_input_field');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

END draw_input_field;
-------------------------------------------------------------------------------

/*
procedure draw_lov_button ( ............ )
IS

BEGIN

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure draw_lov_button');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END draw_lov_button;
*/
------------------------------------------------------------------------------

procedure draw_prompt ( prompt IN VARCHAR2, cspan IN NUMBER )
IS

BEGIN
    NULL;

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure draw_prompt');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

END draw_prompt;
---------------------------------------------------------------------------------

function is_empty_row (
r IN NUMBER,
charid_tab IN qa_ss_const.num_table,
Txn_Num IN NUMBER DEFAULT NULL,
p_col1 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col2 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col3 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col4 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col5 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col6 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col7 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col8 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col9 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col10 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col11 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col12 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col13 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col14 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col15 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col16 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col17 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col18 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col19 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col20 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col21 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col22 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col23 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col24 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col25 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col26 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col27 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col28 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col29 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col30 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col31 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col32 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col33 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col34 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col35 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col36 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col37 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col38 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col39 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col40 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col41 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col42 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col43 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col44 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col45 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col46 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col47 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col48 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col49 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col50 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col51 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col52 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col53 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col54 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col55 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col56 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col57 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col58 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col59 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col60 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col61 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col62 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col63 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col64 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col65 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col66 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col67 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col68 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col69 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col70 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col71 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col72 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col73 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col74 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col75 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col76 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col77 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col78 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col79 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col80 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col81 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col82 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col83 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col84 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col85 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col86 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col87 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col88 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col89 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col90 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col91 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col92 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col93 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col94 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col95 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col96 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col97 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col98 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col99 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col100 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col101 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col102 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col103 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col104 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col105 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col106 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col107 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col108 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col109 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col110 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col111 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col112 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col113 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col114 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col115 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col116 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col117 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col118 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col119 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col120 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col121 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col122 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col123 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col124 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col125 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col126 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col127 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col128 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col129 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col130 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col131 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col132 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col133 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col134 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col135 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col136 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col137 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col138 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col139 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col140 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col141 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col142 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col143 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col144 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col145 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col146 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col147 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col148 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col149 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col150 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col151 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col152 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col153 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col154 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col155 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col156 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col157 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col158 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col159 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
p_col160 IN qa_ss_const.Eqr_Array DEFAULT qa_ss_const.def_array,
planid IN NUMBER DEFAULT NULL )
	Return Boolean

IS

BEGIN

            If charid_tab.Exists(1) Then
		If Not(CxE(charid_tab(1),Txn_Num)) Then
			If (p_col1(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
        -------------------------------------
            If charid_tab.Exists(2) Then
		If Not(CxE(charid_tab(2),Txn_Num)) Then
			If (p_col2(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
        -------------------------------------------
           If charid_tab.Exists(3) Then
		If Not(CxE(charid_tab(3),Txn_Num)) Then
			If (p_col3(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(4) Then
		If Not(CxE(charid_tab(4),Txn_Num)) Then
			If (p_col4(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(5) Then
		If Not(CxE(charid_tab(5),Txn_Num)) Then
			If (p_col5(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(6) Then
		If Not(CxE(charid_tab(6),Txn_Num)) Then
			If (p_col6(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(7) Then
		If Not(CxE(charid_tab(7),Txn_Num)) Then
			If (p_col7(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(8) Then
		If Not(CxE(charid_tab(8),Txn_Num)) Then
			If (p_col8(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(9) Then
		If Not(CxE(charid_tab(9),Txn_Num)) Then
			If (p_col9(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(10) Then
		If Not(CxE(charid_tab(10),Txn_Num)) Then
			If (p_col10(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(11) Then
		If Not(CxE(charid_tab(11),Txn_Num)) Then
			If (p_col11(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(12) Then
		If Not(CxE(charid_tab(12),Txn_Num)) Then
			If (p_col12(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(13) Then
		If Not(CxE(charid_tab(13),Txn_Num)) Then
			If (p_col13(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(14) Then
		If Not(CxE(charid_tab(14),Txn_Num)) Then
			If (p_col14(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(15) Then
		If Not(CxE(charid_tab(15),Txn_Num)) Then
			If (p_col15(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(16) Then
		If Not(CxE(charid_tab(16),Txn_Num)) Then
			If (p_col16(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(17) Then
		If Not(CxE(charid_tab(17),Txn_Num)) Then
			If (p_col17(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(18) Then
		If Not(CxE(charid_tab(18),Txn_Num)) Then
			If (p_col18(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(19) Then
		If Not(CxE(charid_tab(19),Txn_Num)) Then
			If (p_col19(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(20) Then
		If Not(CxE(charid_tab(20),Txn_Num)) Then
			If (p_col20(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(21) Then
		If Not(CxE(charid_tab(21),Txn_Num)) Then
			If (p_col21(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(22) Then
		If Not(CxE(charid_tab(22),Txn_Num)) Then
			If (p_col22(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(23) Then
		If Not(CxE(charid_tab(23),Txn_Num)) Then
			If (p_col23(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(24) Then
		If Not(CxE(charid_tab(24),Txn_Num)) Then
			If (p_col24(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(25) Then
		If Not(CxE(charid_tab(25),Txn_Num)) Then
			If (p_col25(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(26) Then
		If Not(CxE(charid_tab(26),Txn_Num)) Then
			If (p_col26(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(27) Then
		If Not(CxE(charid_tab(27),Txn_Num)) Then
			If (p_col27(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(28) Then
		If Not(CxE(charid_tab(28),Txn_Num)) Then
			If (p_col28(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(29) Then
		If Not(CxE(charid_tab(29),Txn_Num)) Then
			If (p_col29(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(30) Then
		If Not(CxE(charid_tab(30),Txn_Num)) Then
			If (p_col30(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(31) Then
		If Not(CxE(charid_tab(31),Txn_Num)) Then
			If (p_col31(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(32) Then
		If Not(CxE(charid_tab(32),Txn_Num)) Then
			If (p_col32(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(33) Then
		If Not(CxE(charid_tab(33),Txn_Num)) Then
			If (p_col33(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(34) Then
		If Not(CxE(charid_tab(34),Txn_Num)) Then
			If (p_col34(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(35) Then
		If Not(CxE(charid_tab(35),Txn_Num)) Then
			If (p_col35(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(36) Then
		If Not(CxE(charid_tab(36),Txn_Num)) Then
			If (p_col36(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(37) Then
		If Not(CxE(charid_tab(37),Txn_Num)) Then
			If (p_col37(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(38) Then
		If Not(CxE(charid_tab(38),Txn_Num)) Then
			If (p_col38(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(39) Then
		If Not(CxE(charid_tab(39),Txn_Num)) Then
			If (p_col39(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(40) Then
		If Not(CxE(charid_tab(40),Txn_Num)) Then
			If (p_col40(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(41) Then
		If Not(CxE(charid_tab(41),Txn_Num)) Then
			If (p_col41(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(42) Then
		If Not(CxE(charid_tab(42),Txn_Num)) Then
			If (p_col42(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(43) Then
		If Not(CxE(charid_tab(43),Txn_Num)) Then
			If (p_col43(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(44) Then
		If Not(CxE(charid_tab(44),Txn_Num)) Then
			If (p_col44(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(45) Then
		If Not(CxE(charid_tab(45),Txn_Num)) Then
			If (p_col45(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(46) Then
		If Not(CxE(charid_tab(46),Txn_Num)) Then
			If (p_col46(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(47) Then
		If Not(CxE(charid_tab(47),Txn_Num)) Then
			If (p_col47(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(48) Then
		If Not(CxE(charid_tab(48),Txn_Num)) Then
			If (p_col48(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(49) Then
		If Not(CxE(charid_tab(49),Txn_Num)) Then
			If (p_col49(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(50) Then
		If Not(CxE(charid_tab(50),Txn_Num)) Then
			If (p_col50(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(51) Then
		If Not(CxE(charid_tab(51),Txn_Num)) Then
			If (p_col51(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(52) Then
		If Not(CxE(charid_tab(52),Txn_Num)) Then
			If (p_col52(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(53) Then
		If Not(CxE(charid_tab(53),Txn_Num)) Then
			If (p_col53(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(54) Then
		If Not(CxE(charid_tab(54),Txn_Num)) Then
			If (p_col54(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(55) Then
		If Not(CxE(charid_tab(55),Txn_Num)) Then
			If (p_col55(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(56) Then
		If Not(CxE(charid_tab(56),Txn_Num)) Then
			If (p_col56(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(57) Then
		If Not(CxE(charid_tab(57),Txn_Num)) Then
			If (p_col57(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(58) Then
		If Not(CxE(charid_tab(58),Txn_Num)) Then
			If (p_col58(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(59) Then
		If Not(CxE(charid_tab(59),Txn_Num)) Then
			If (p_col59(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(60) Then
		If Not(CxE(charid_tab(60),Txn_Num)) Then
			If (p_col60(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(61) Then
		If Not(CxE(charid_tab(61),Txn_Num)) Then
			If (p_col61(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(62) Then
		If Not(CxE(charid_tab(62),Txn_Num)) Then
			If (p_col62(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(63) Then
		If Not(CxE(charid_tab(63),Txn_Num)) Then
			If (p_col63(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(64) Then
		If Not(CxE(charid_tab(64),Txn_Num)) Then
			If (p_col64(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(65) Then
		If Not(CxE(charid_tab(65),Txn_Num)) Then
			If (p_col65(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(66) Then
		If Not(CxE(charid_tab(66),Txn_Num)) Then
			If (p_col66(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(67) Then
		If Not(CxE(charid_tab(67),Txn_Num)) Then
			If (p_col67(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(68) Then
		If Not(CxE(charid_tab(68),Txn_Num)) Then
			If (p_col68(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(69) Then
		If Not(CxE(charid_tab(69),Txn_Num)) Then
			If (p_col69(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(70) Then
		If Not(CxE(charid_tab(70),Txn_Num)) Then
			If (p_col70(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(71) Then
		If Not(CxE(charid_tab(71),Txn_Num)) Then
			If (p_col71(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(72) Then
		If Not(CxE(charid_tab(72),Txn_Num)) Then
			If (p_col72(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(73) Then
		If Not(CxE(charid_tab(73),Txn_Num)) Then
			If (p_col73(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(74) Then
		If Not(CxE(charid_tab(74),Txn_Num)) Then
			If (p_col74(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(75) Then
		If Not(CxE(charid_tab(75),Txn_Num)) Then
			If (p_col75(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(76) Then
		If Not(CxE(charid_tab(76),Txn_Num)) Then
			If (p_col76(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(77) Then
		If Not(CxE(charid_tab(77),Txn_Num)) Then
			If (p_col77(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(78) Then
		If Not(CxE(charid_tab(78),Txn_Num)) Then
			If (p_col78(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(79) Then
		If Not(CxE(charid_tab(79),Txn_Num)) Then
			If (p_col79(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(80) Then
		If Not(CxE(charid_tab(80),Txn_Num)) Then
			If (p_col80(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(81) Then
		If Not(CxE(charid_tab(81),Txn_Num)) Then
			If (p_col81(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(82) Then
		If Not(CxE(charid_tab(82),Txn_Num)) Then
			If (p_col82(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(83) Then
		If Not(CxE(charid_tab(83),Txn_Num)) Then
			If (p_col83(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(84) Then
		If Not(CxE(charid_tab(84),Txn_Num)) Then
			If (p_col84(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(85) Then
		If Not(CxE(charid_tab(85),Txn_Num)) Then
			If (p_col85(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(86) Then
		If Not(CxE(charid_tab(86),Txn_Num)) Then
			If (p_col86(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(87) Then
		If Not(CxE(charid_tab(87),Txn_Num)) Then
			If (p_col87(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(88) Then
		If Not(CxE(charid_tab(88),Txn_Num)) Then
			If (p_col88(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(89) Then
		If Not(CxE(charid_tab(89),Txn_Num)) Then
			If (p_col89(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(90) Then
		If Not(CxE(charid_tab(90),Txn_Num)) Then
			If (p_col90(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(91) Then
		If Not(CxE(charid_tab(91),Txn_Num)) Then
			If (p_col91(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(92) Then
		If Not(CxE(charid_tab(92),Txn_Num)) Then
			If (p_col92(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(93) Then
		If Not(CxE(charid_tab(93),Txn_Num)) Then
			If (p_col93(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(94) Then
		If Not(CxE(charid_tab(94),Txn_Num)) Then
			If (p_col94(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(95) Then
		If Not(CxE(charid_tab(95),Txn_Num)) Then
			If (p_col95(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(96) Then
		If Not(CxE(charid_tab(96),Txn_Num)) Then
			If (p_col96(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(97) Then
		If Not(CxE(charid_tab(97),Txn_Num)) Then
			If (p_col97(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(98) Then
		If Not(CxE(charid_tab(98),Txn_Num)) Then
			If (p_col98(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(99) Then
		If Not(CxE(charid_tab(99),Txn_Num)) Then
			If (p_col99(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(100) Then
		If Not(CxE(charid_tab(100),Txn_Num)) Then
			If (p_col100(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(101) Then
		If Not(CxE(charid_tab(101),Txn_Num)) Then
			If (p_col101(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(102) Then
		If Not(CxE(charid_tab(102),Txn_Num)) Then
			If (p_col102(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(103) Then
		If Not(CxE(charid_tab(103),Txn_Num)) Then
			If (p_col103(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(104) Then
		If Not(CxE(charid_tab(104),Txn_Num)) Then
			If (p_col104(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(105) Then
		If Not(CxE(charid_tab(105),Txn_Num)) Then
			If (p_col105(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(106) Then
		If Not(CxE(charid_tab(106),Txn_Num)) Then
			If (p_col106(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(107) Then
		If Not(CxE(charid_tab(107),Txn_Num)) Then
			If (p_col107(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(108) Then
		If Not(CxE(charid_tab(108),Txn_Num)) Then
			If (p_col108(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(109) Then
		If Not(CxE(charid_tab(109),Txn_Num)) Then
			If (p_col109(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(110) Then
		If Not(CxE(charid_tab(110),Txn_Num)) Then
			If (p_col110(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(111) Then
		If Not(CxE(charid_tab(111),Txn_Num)) Then
			If (p_col111(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(112) Then
		If Not(CxE(charid_tab(112),Txn_Num)) Then
			If (p_col112(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(113) Then
		If Not(CxE(charid_tab(113),Txn_Num)) Then
			If (p_col113(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(114) Then
		If Not(CxE(charid_tab(114),Txn_Num)) Then
			If (p_col114(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(115) Then
		If Not(CxE(charid_tab(115),Txn_Num)) Then
			If (p_col115(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(116) Then
		If Not(CxE(charid_tab(116),Txn_Num)) Then
			If (p_col116(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(117) Then
		If Not(CxE(charid_tab(117),Txn_Num)) Then
			If (p_col117(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(118) Then
		If Not(CxE(charid_tab(118),Txn_Num)) Then
			If (p_col118(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(119) Then
		If Not(CxE(charid_tab(119),Txn_Num)) Then
			If (p_col119(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(120) Then
		If Not(CxE(charid_tab(120),Txn_Num)) Then
			If (p_col120(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(121) Then
		If Not(CxE(charid_tab(121),Txn_Num)) Then
			If (p_col121(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(122) Then
		If Not(CxE(charid_tab(122),Txn_Num)) Then
			If (p_col122(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(123) Then
		If Not(CxE(charid_tab(123),Txn_Num)) Then
			If (p_col123(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(124) Then
		If Not(CxE(charid_tab(124),Txn_Num)) Then
			If (p_col124(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(125) Then
		If Not(CxE(charid_tab(125),Txn_Num)) Then
			If (p_col125(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(126) Then
		If Not(CxE(charid_tab(126),Txn_Num)) Then
			If (p_col126(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(127) Then
		If Not(CxE(charid_tab(127),Txn_Num)) Then
			If (p_col127(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(128) Then
		If Not(CxE(charid_tab(128),Txn_Num)) Then
			If (p_col128(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(129) Then
		If Not(CxE(charid_tab(129),Txn_Num)) Then
			If (p_col129(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(130) Then
		If Not(CxE(charid_tab(130),Txn_Num)) Then
			If (p_col130(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(131) Then
		If Not(CxE(charid_tab(131),Txn_Num)) Then
			If (p_col131(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(132) Then
		If Not(CxE(charid_tab(132),Txn_Num)) Then
			If (p_col132(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(133) Then
		If Not(CxE(charid_tab(133),Txn_Num)) Then
			If (p_col133(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(134) Then
		If Not(CxE(charid_tab(134),Txn_Num)) Then
			If (p_col134(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(135) Then
		If Not(CxE(charid_tab(135),Txn_Num)) Then
			If (p_col135(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(136) Then
		If Not(CxE(charid_tab(136),Txn_Num)) Then
			If (p_col136(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(137) Then
		If Not(CxE(charid_tab(137),Txn_Num)) Then
			If (p_col137(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(138) Then
		If Not(CxE(charid_tab(138),Txn_Num)) Then
			If (p_col138(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(139) Then
		If Not(CxE(charid_tab(139),Txn_Num)) Then
			If (p_col139(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(140) Then
		If Not(CxE(charid_tab(140),Txn_Num)) Then
			If (p_col140(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(141) Then
		If Not(CxE(charid_tab(141),Txn_Num)) Then
			If (p_col141(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(142) Then
		If Not(CxE(charid_tab(142),Txn_Num)) Then
			If (p_col142(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(143) Then
		If Not(CxE(charid_tab(143),Txn_Num)) Then
			If (p_col143(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(144) Then
		If Not(CxE(charid_tab(144),Txn_Num)) Then
			If (p_col144(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(145) Then
		If Not(CxE(charid_tab(145),Txn_Num)) Then
			If (p_col145(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(146) Then
		If Not(CxE(charid_tab(146),Txn_Num)) Then
			If (p_col146(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(147) Then
		If Not(CxE(charid_tab(147),Txn_Num)) Then
			If (p_col147(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(148) Then
		If Not(CxE(charid_tab(148),Txn_Num)) Then
			If (p_col148(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(149) Then
		If Not(CxE(charid_tab(149),Txn_Num)) Then
			If (p_col149(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(150) Then
		If Not(CxE(charid_tab(150),Txn_Num)) Then
			If (p_col150(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(151) Then
		If Not(CxE(charid_tab(151),Txn_Num)) Then
			If (p_col151(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(152) Then
		If Not(CxE(charid_tab(152),Txn_Num)) Then
			If (p_col152(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(153) Then
		If Not(CxE(charid_tab(153),Txn_Num)) Then
			If (p_col153(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(154) Then
		If Not(CxE(charid_tab(154),Txn_Num)) Then
			If (p_col154(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(155) Then
		If Not(CxE(charid_tab(155),Txn_Num)) Then
			If (p_col155(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(156) Then
		If Not(CxE(charid_tab(156),Txn_Num)) Then
			If (p_col156(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(157) Then
		If Not(CxE(charid_tab(157),Txn_Num)) Then
			If (p_col157(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(158) Then
		If Not(CxE(charid_tab(158),Txn_Num)) Then
			If (p_col158(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(159) Then
		If Not(CxE(charid_tab(159),Txn_Num)) Then
			If (p_col159(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;
            If charid_tab.Exists(160) Then
		If Not(CxE(charid_tab(160),Txn_Num)) Then
			If (p_col160(r) is Not Null) Then
				return FALSE;
			End If;
		End If;
	     End If;

        Return TRUE; -- If all failed, return TRUE to signal empty row
EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in function is_empty_row');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END is_empty_row;
------------------------------------------------------------------------------------


function any_applicable_plans ( Ctx IN qa_ss_const.Ctx_Table,
				Txn_Number IN NUMBER,
				organization_id IN NUMBER )
	Return BOOLEAN

IS
    Dummy_tab qa_ss_const.num_table;


BEGIN
    -- sanity check: dont think icx_sec.validatesession is needed here
    -- becos this function is part of wip's osp view
    -- but mentioning this comment as a check


        NULL;

            Return Evaluate_Triggers(Ctx, Txn_Number, organization_id,
                            Dummy_tab, 2);

            -- The 2 above is an optimization hint to my Evaluate_triggers
            -- function which may be used in the future. Signifies, return
            -- after the first applicable plan is found. Dont search for more


EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in function any_applicable_plans');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
        -- anagarwa Thu Nov  8 11:24:34 PST 2001
        -- Following return added to handle following problem (Bug #2101177) :
        -- ORA-06503: PL/SQL: Function returned without value
        -- ORA-06512: at "APPS.QA_SS_CORE", line 3327
        -- ORA-06512: at "APPS.QA_SS_OSP", line 48
        -- ORA-06512: at line 1
        RETURN FALSE;
END any_applicable_plans;
----------------------------------------------------------------------------------------

procedure  all_applicable_plans ( Ctx IN qa_ss_const.Ctx_Table,
				  Txn_Number IN NUMBER,
				  organization_id IN NUMBER,
				PK1 IN VARCHAR2 DEFAULT NULL,
				PK2 IN VARCHAR2 DEFAULT NULL,
				PK3 IN VARCHAR2 DEFAULT NULL,
				PK4 IN VARCHAR2 DEFAULT NULL,
				PK5 IN VARCHAR2 DEFAULT NULL,
				PK6 IN VARCHAR2 DEFAULT NULL,
				PK7 IN VARCHAR2 DEFAULT NULL,
				PK8 IN VARCHAR2 DEFAULT NULL,
				PK9 IN VARCHAR2 DEFAULT NULL,
				PK10 IN VARCHAR2 DEFAULT NULL)

IS
    Pid_table qa_ss_const.num_table;
    ret_val boolean;
BEGIN
    if (icx_sec.validatesession) then

        NULL;

            ret_val := Evaluate_Triggers(Ctx, Txn_Number, organization_id,
                                Pid_table, 1);
            -- The 1 above is Flag value to the procedure
            -- ignore the ret_val in this case

            List_Plans (Pid_table, Txn_Number, organization_id,
                        pk1, pk2, pk3, pk4, pk5, pk6, pk7, pk8, pk9, pk10);


    end if; -- end icx session

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in procedure all_applicable_plans');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END all_applicable_plans;
-------------------------------------------------------------------------------------------

function Evaluate_Triggers ( Ctx IN qa_ss_const.Ctx_Table,
				x_Txn_Number IN NUMBER,
				x_organization_id IN NUMBER,
				Pid_tab IN OUT NOCOPY qa_ss_const.num_Table,
				Flag IN NUMBER )
RETURN BOOLEAN
        -- The Flag above is an optimization hint to my Evaluate_triggers
            -- function which may be used in the future. Signifies, return
            -- after the first applicable plan is found. Dont search for more
            -- if the Flag value is 2. Otherwise, find all the applic. plans

        -- When the Flag is 2, the return value of the Function is what
        -- is significant. If the return value is TRUE, that means plans
        -- are applicable. In this case, the Pid_tab can be IGNORED
        -- When Flag is Not 2, then Pid_Tab will contain list of
        -- all applicable plan ids
IS

Cursor coll_trigg_cur is
	SELECT qpt.Plan_transaction_id,
		qpt.Plan_id,
		qc.char_id,
        qc.dependent_char_id,
		qc.datatype,
		qpct.Operator,
		qpct.Low_Value,
		qpct.High_Value
	FROM qa_plan_collection_triggers qpct,
		qa_plan_transactions qpt,
		qa_plans_val_v qp,
        qa_chars qc,
		qa_txn_collection_triggers qtct
	WHERE qpt.Plan_ID = qp.Plan_ID
	AND qpct.Plan_Transaction_ID(+) = qpt.Plan_Transaction_ID
        AND qpct.Collection_Trigger_ID = qtct.Collection_Trigger_ID(+)
        AND qpct.Collection_Trigger_ID = qc.char_id(+)
	AND qpt.TRANSACTION_NUMBER = x_txn_number
        AND qtct.TRANSACTION_NUMBER(+) = x_txn_number
        AND qp.ORGANIZATION_ID = x_organization_id
        AND qpt.enabled_flag = 1
ORDER BY qpt.plan_transaction_id;

Type Coll_Trigg_Type is TABLE of coll_trigg_cur%ROWTYPE INDEX BY BINARY_INTEGER;
Coll_Trigg_Tab  Coll_Trigg_Type;

plan_is_applicable BOOLEAN;
counter INTEGER;
i INTEGER := 1;

l_rowcount INTEGER;

l_datatype NUMBER;
l_operator NUMBER;
l_low_char VARCHAR2(150);
l_high_char VARCHAR2(150);
l_low_number NUMBER;
l_high_number NUMBER;
l_low_date DATE;
l_high_date DATE;
l_value_char VARCHAR2(150);
l_value_number NUMBER;
l_value_date DATE;

l_plan_id	NUMBER;
l_old_plan_id NUMBER;

l_plan_txn_id NUMBER ;
l_old_plan_txn_id NUMBER ;


l_char_id NUMBER;
l_dep_char_id NUMBER;
pid_count NUMBER := 0;
atleast_one BOOLEAN;
    -- All variables beginning with l_ are local variables
BEGIN
    atleast_one := FALSE;
    counter := 1;
	For ct_rec in coll_trigg_cur
	loop
		coll_trigg_tab(counter) := ct_rec;
		counter := counter + 1;
	end loop;

	l_rowcount := coll_trigg_tab.count;

    if (l_rowcount < 1) Then
        return FALSE; -- no plans applicable
    end if;

    l_plan_txn_id := coll_trigg_tab(1).plan_transaction_id;

        -- The variable i has been  initialized to 1

        WHILE ( i <= l_rowcount)
        LOOP
            l_old_plan_txn_id := l_plan_txn_id;
            plan_is_applicable := TRUE; -- start with this assumption

            WHILE (l_plan_txn_id = l_old_plan_txn_id) AND (i <= l_rowcount)
            LOOP
                IF (plan_is_applicable = TRUE)
                THEN
                        l_operator := coll_trigg_tab(i).Operator;
                        l_datatype := coll_trigg_tab(i).Datatype;
                        l_char_id := coll_trigg_tab(i).char_id;
                        IF (l_operator is NULL) AND (l_datatype is NULL)
                        THEN
                            null;
                                -- null collection trigger. Plan applies
                        ELSE
                            -- WATCH OUT FOR EXCEPTIONS while
                            -- accessing Ctx table below
                                IF (qltcompb.compare( Ctx(l_char_id),
                                                  l_operator,
                                                  coll_trigg_tab(i).Low_value,
                                                  coll_trigg_tab(i).High_Value,
                                                  l_datatype)  )
                                    -- above is a overloaded call
                                THEN
                                        plan_is_applicable := TRUE;
                                ELSE
                                        plan_is_applicable := FALSE;
                                END IF; --end qltcompb
                         END IF;  -- end l_operator and l_datatype null
               END IF; -- end Check plan applicable is true

                i := i+1;
                IF (i <= l_rowcount) THEN
                        l_plan_txn_id := coll_trigg_tab(i).plan_transaction_id;
                END IF;
             END LOOP; -- end inner while loop
             IF (plan_is_applicable = TRUE) THEN
                        atleast_one := TRUE;
                        -- if flag is 2, stop here itself and return True
                        IF (Flag = 2) THEN
                            RETURN TRUE;
                        END IF;
                        -- if flag is not 2, then keep continuing
                        pid_count := pid_count + 1;
                            -- at very beginning pid_count is ZERO
                        Pid_tab(pid_count) := coll_trigg_tab(i-1).plan_id;
              END IF;
      END LOOP; -- end outer while loop

	       RETURN atleast_one;

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in function Evaluate_Triggers');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
        -- anagarwa Thu Nov  8 11:24:34 PST 2001
        -- Following return added to handle following problem (Bug #2101177) :
        -- ORA-06503: PL/SQL: Function returned without value
        -- ORA-06512: at "APPS.QA_SS_CORE", line 3327
        -- ORA-06512: at "APPS.QA_SS_OSP", line 48
        -- ORA-06512: at line 1
        RETURN FALSE;
END Evaluate_Triggers;
----------------------------------------------------------------------------------------------

procedure generate_eqr_javascript

IS

BEGIN

    htp.p('<SCRIPT LANGUAGE="JavaScript">');
		htp.p('var lov_win;');
		htp.p('function sayhello()
			{
				alert("Hello Quality User");
			}');

		htp.p('function LOV(rowno,charid, colno, itm)
			{
			 var fldval;

			 fldval = itm.value; //remember itm is a reference
					    // to the field and not a string
					    // so itm.value can be said

			 fldval = escape(fldval);
             lov_win = window.open("qa_ss_lov.gen_list?vchar_id="+charid+"&rnumb="+rowno+
                        "&cnumb="+colno+"&find1="+fldval, "LOV",
                        "resizable=yes,menubar=yes,scrollbar=yes,width=780,height=300");

             lov_win.opener = self;
             }');

		htp.p('</SCRIPT>');

EXCEPTION

    WHEN OTHERS THEN
        htp.p('Exception in procedure generate_eqr_javascript');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END generate_eqr_javascript;
-------------------------------------------------------------------------------------------------
procedure List_Plans ( Pid_tab IN qa_ss_const.num_table,
                    txn_num IN NUMBER DEFAULT NULL,
                    orgz_id IN NUMBER DEFAULT NULL,
        			PK1 IN VARCHAR2 DEFAULT NULL,
		          	PK2 IN VARCHAR2 DEFAULT NULL,
			        PK3 IN VARCHAR2 DEFAULT NULL,
			        PK4 IN VARCHAR2 DEFAULT NULL,
			        PK5 IN VARCHAR2 DEFAULT NULL,
			        PK6 IN VARCHAR2 DEFAULT NULL,
			        PK7 IN VARCHAR2 DEFAULT NULL,
			        PK8 IN VARCHAR2 DEFAULT NULL,
			        PK9 IN VARCHAR2 DEFAULT NULL,
			        PK10 IN VARCHAR2 DEFAULT NULL )

IS
        l_language_code varchar2(30);
        no_of_plans NUMBER;
        pid_i NUMBER;
        pname varchar2(40);
        pdesc varchar2(30);
        ptype varchar2(30);
        enterurl varchar2(10000);
        viewurl  varchar2(2000);
        attachurl varchar2(200);
        atchmt varchar2(50);
        show_eqr BOOLEAN := TRUE;
	row_color VARCHAR2(10) := 'BLUE';
        osp_job_ok BOOLEAN := TRUE;

        CURSOR plan_cur (X_Pid NUMBER)
        IS
            Select qp.name, qp.description, fcl.meaning
            from qa_plans qp, fnd_common_lookups fcl
            where qp.plan_id = X_Pid
            and qp.plan_type_code = fcl.lookup_code
            and fcl.lookup_type = 'COLLECTION_PLAN_TYPE'
            Order By qp.name;

        plan_rec plan_cur%ROWTYPE;

BEGIN
    if (icx_sec.validatesession) then

        l_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

        -- Added new function security July 30, 1999
        show_eqr := FND_FUNCTION.TEST('ICX_QA_ENTER_QUALITY');

	-- Below IF stmts for Bug 999521
	IF (show_eqr) THEN
		IF (txn_num=100) THEN -- osp transaction
			osp_job_ok := Is_Job_Valid(to_number(PK1),
						   to_number(PK2));
                        show_eqr := osp_job_ok;
			-- private function in beginning of this pkg
			-- NOTE: For OSP, pk1 is po_distribution_id
			-- and pk2 is wip_entity_id
		END IF;
	END IF;

        htp.p('<HTML>');
        htp.p('<HEAD>');

        /*  -- Javascript COMMENTED OUT
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('function view_results(plan_id)
                {
                    window.location = "qa_ss_core.VQR?plan_id_i="+plan_id;
                 }');
        htp.p('function enter_results(plan_id, txn, oid, p1, p2, p3, p4, p5, p6, p7,p8, p9, p10)
                {
                    window.location = "qa_ss_core.draw_frames?plan_id_i="+plan_id+"'
                                    || '&' || 'txn_num="+txn+"'
                                    || '&' || 'orgz_id="+oid+"'
                                    || '&' || 'pk1="+p1+"'
                                    || '&' || 'pk2="+p2+"'
                                    || '&' || 'pk3="+p3+"'
                                    || '&' || 'pk4="+p4+"'
                                    || '&' || 'pk5="+p5+"'
                                    || '&' || 'pk6="+p6+"'
                                    || '&' || 'pk7="+p7+"'
                                    || '&' || 'pk8="+p8+"'
                                    || '&' || 'pk9="+p9+"'
                                    || '&' || 'pk10="+p10;
                }');

         htp.p('</SCRIPT>');
         */ -- COMMENTED OUT ABOVE

        htp.p('</HEAD>');
        htp.p('<BODY bgcolor=#cccccc>');

            -- icx_admin_sig.toolbar(language_code => l_language_code);
            -- icx_plug_utilities.plugbanner(fnd_message.get_string('QA', 'QA_SS_COLL_PLANS'));
		if (NOT osp_job_ok) THEN
		htp.p(fnd_message.get_string('QA', 'QA_SS_INVALID_JOB'));
                end if;
            htp.formOpen('');
            htp.br;
            htp.tableOpen(cborder=>'BORDER=2', cattributes=>'CELLPADDING=2');
            htp.tableRowOpen (cattributes=>'BGCOLOR="#336699"');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                    fnd_message.get_string('QA', 'QA_SS_CP_HEADING')
                    || '</font>', calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA', 'QA_SS_DESC'), calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                    'Type'|| '</font>', calign=>'CENTER');
                if (show_eqr) THEN
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA', 'QA_SS_ENTER_BUTTON')|| '</font>', calign=>'CENTER');
                END IF;
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA', 'QA_SS_VIEW_BUTTON')|| '</font>', calign=>'CENTER');
                htp.tableHeader(cvalue=>'<font color=#ffffff>'||
                        fnd_message.get_string('QA',  'QA_SS_ATTACH_BUTTON')|| '</font>', calign=>'CENTER');
            htp.tableRowClose;
            htp.p('<TR></TR><TR></TR>');

            -- Loop goes in here
            no_of_plans := Pid_tab.count;
            For i in 1..no_of_plans
            Loop
                    pid_i := Pid_tab(i);

                enterurl  := 'qa_ss_core.draw_frames?plan_id_i=' || pid_i
                                               || '&' || 'txn_num=' || Txn_Num
                                               || '&' || 'orgz_id=' || orgz_id
                                               || '&' || 'pk1=' || pk1
                                               || '&' || 'pk2=' || pk2
                                               || '&' || 'pk3=' || pk3
                                               || '&' || 'pk4=' || pk4
                                               || '&' || 'pk5=' || pk5
                                               || '&' || 'pk6=' || pk6
                                               || '&' || 'pk7=' || pk7
                                               || '&' || 'pk8=' || pk8
                                               || '&' || 'pk9=' || pk9
                                               || '&' || 'pk10=' || pk10;

                viewurl := 'qa_ss_core.VQR_Frames?plan_id_i=' || pid_i
					|| '&'
					|| 'ss_where_clause=';
                attachurl := 'qa_ss_attachment.qa_plans_view_attachment?plan_id=' || pid_i;
		-- viewurl := 'qa_results_interface_pkg.Proc1?x=100';

                    atchmt := qa_ss_attachment.qa_plans_attachment_status(pid_i);

                 OPEN plan_cur(pid_i);
                 FETCH plan_cur INTO plan_rec;
                pname := substr(plan_rec.name,1,30);
                pdesc := NVL(substr(plan_rec.description,1,20), '&nbsp');
                ptype := NVL(substr(plan_rec.meaning,1,20), '&nbsp');

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
                IF (show_eqr) THEN
                htp.tableData(htf.anchor(enterurl, fnd_message.get_string('QA','QA_SS_ENTER_BUTTON'), cattributes=>'TARGET="enterwin"'));
                END IF;
                htp.tableData(htf.anchor(viewurl, fnd_message.get_string('QA','QA_SS_VIEW_BUTTON'), cattributes=>'TARGET="viewwin"'));
                if (atchmt = 'FULL') then
                    htp.tableData(htf.anchor(attachurl,
			fnd_message.get_string('QA','QA_SS_AVAILABLE'),
				 cattributes=>'TARGET="attwin"'));
                else
                    htp.tableData('&'||'nbsp');
                end if;

                 CLOSE plan_cur;
            End Loop; -- end of forloop for all rows in list of plans

                -- Bottom header is below
                /*
             htp.p('<TR></TR><TR></TR>');
              htp.tableRowOpen (cattributes=>'BGCOLOR="#83C1C1"');
                htp.tableHeader(cvalue=>fnd_message.get_string('QA', 'QA_SS_CP_HEADING'), calign=>'CENTER');
                htp.tableHeader(cvalue=>fnd_message.get_string('QA', 'QA_SS_DESC'), calign=>'CENTER');
                htp.tableHeader(cvalue=>'Type', calign=>'CENTER');
                IF (show_eqr) THEN
                htp.tableHeader(cvalue=>fnd_message.get_string('QA', 'QA_SS_ENTER_BUTTON'), calign=>'CENTER');
                END IF;
                htp.tableHeader(cvalue=>fnd_message.get_string('QA', 'QA_SS_VIEW_BUTTON'), calign=>'CENTER');
                htp.tableHeader(cvalue=>fnd_message.get_string('QA',  'QA_SS_ATTACH_BUTTON'), calign=>'CENTER');
            htp.tableRowClose;
            */
             htp.tableClose;
             htp.formClose;


        htp.p('</BODY>');

        htp.p('</HTML>');

    NULL;
    end if; -- end icx session


EXCEPTION
     WHEN OTHERS THEN
            If plan_cur%ISOPEN Then
                CLOSE plan_cur;
            End if;

        htp.p('Exception in QA_SS_CORE.List_Plans');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END List_Plans;

---------------------------------------------------------------------------------------------------
procedure Plan_List_Frames (
            txn_num IN NUMBER DEFAULT NULL,
            PK1 IN VARCHAR2 DEFAULT NULL,
			PK2 IN VARCHAR2 DEFAULT NULL,
			PK3 IN VARCHAR2 DEFAULT NULL,
			PK4 IN VARCHAR2 DEFAULT NULL,
			PK5 IN VARCHAR2 DEFAULT NULL,
			PK6 IN VARCHAR2 DEFAULT NULL,
			PK7 IN VARCHAR2 DEFAULT NULL,
			PK8 IN VARCHAR2 DEFAULT NULL,
			PK9 IN VARCHAR2 DEFAULT NULL,
			PK10 IN VARCHAR2 DEFAULT NULL )
IS
    url_str VARCHAR2(1000);
    toolbar_heading VARCHAR2(500);
    l_language_code VARCHAR2(30);
 BEGIN

	l_language_code := ICX_Sec.GetId(ICX_SEC.PV_LANGUAGE_CODE);

        IF (txn_num=100) then
            url_str :='qa_ss_osp.osp_plans';
        ELSIF (txn_num=110) then
            url_str := 'qa_ss_ship.shipping_plans';
        END IF;

        htp.p('<HTML>');
        htp.p('<TITLE>'||fnd_message.get_string('QA', 'QA_SS_COLL_PLANS')||'</TITLE>');
        htp.p('<HEAD>');
        htp.p('<LINK REL="STYLESHEET" HREF="/OA_HTML/'
			||l_language_code||'/POSSTYLE.css">');


        htp.p('<script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
        htp.p('</script>');
        htp.p('<script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
        htp.p('</script>');
        htp.p('<script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
        htp.p('</script>');

        js.scriptOpen;
        pos_global_vars_sv.InitializeMessageArray;
        js.scriptClose;
        htp.p('</HEAD>');

	toolbar_heading := fnd_message.get_string('QA', 'QA_SS_COLL_PLANS');
	toolbar_heading := wfa_html.conv_special_url_chars(toolbar_heading);
        htp.p('<frameset rows="50,*,40" border=0>');
        htp.p('<frame src="pos_toolbar_sv.PaintToolbar?p_title='||toolbar_heading||'"
                name=toolbar
                marginwidth=6
                marginheight=2
                scrolling=no>');
        htp.p('<frameset cols="3,*,3" border=0>');
        htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
                name=borderLeft
                marginwidth=0
                marginheight=0
                scrolling=no>');
        htp.p('<frameset rows="30,*,5" border=0>');
        htp.p('<frame src="pos_upper_banner_sv.PaintUpperBanner?p_product=QA'||'&'||'p_title=QA_SS_COLL_PLANS"
                name=upperbanner
                marginwidth=0
                marginheight=0
                scrolling=no>');




        htp.p('<frame src="'||url_str||'?pk1='||pk1
                            ||'&'||'pk2='||pk2
                            ||'&'||'pk3='||pk3
                            ||'&'||'pk4='||pk4
                            ||'&'||'pk5='||pk5
                            ||'&'||'pk6='||pk6
                            ||'&'||'pk7='||pk7
                            ||'&'||'pk8='||pk8
                            ||'&'||'pk9='||pk9
                            ||'&'||'pk10='||pk10||'"
                name=content
                marginwidth=0
                marginheight=0
                scrolling=yes>');



                /*   -- BELOW ONLY FOR DEBUG
                 htp.p('<frame src="qa_ss_core.draw_table?plan_id_i=1941&txn_num=100&orgz_id=207&pk1=4891"
                name=content
                marginwidth=0
                marginheight=0
                scrolling=yes>');
                */
            htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSLWBAN.htm"
                name=lowerbanner
                marginwidth=0
                marginheight=0
                scrolling=no>');

         htp.p('</frameset>');
         htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
                name=borderRight
                marginwidth=0
                marginheight=0
                scrolling=no>');
         htp.p('</frameset>');
          htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
                name=bottomregion
                marginwidth=0
                marginheight=0
                scrolling=no>');
          htp.p('</frameset>');
          htp.p('</HTML>');

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in QA_SS_CORE.Plan_List_Frames');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END Plan_List_Frames;
----------------------------------------------------------------------------------------------------
--
-- Bug 22176228
-- Stubbing out the API to avoid security issue due to
-- SQL injection through ss_where_clause
-- ntungare
--
procedure VQR_Frames(plan_id_i IN qa_plans.plan_id%TYPE,
			ss_where_clause in varchar2 default null)
IS
--	toolbar_heading VARCHAR2(500);
--    l_plan_name VARCHAR2(50);
--	l_language_code VARCHAR2(30);
--	ss_w_c varchar2(5000) := NULL;
--
--    CURSOR plan_name_cur IS
--	SELECT name
--	FROM QA_PLANS
--	WHERE plan_id = plan_id_i ;

BEGIN
--    if (icx_sec.validateSession) THEN
--
--	l_language_code := ICX_Sec.GetId(icx_sec.PV_LANGUAGE_CODE);
--
--	OPEN plan_name_cur;
--	FETCH plan_name_cur INTO l_plan_name;
--	CLOSE plan_name_cur;
--
--        htp.p('<HTML>');
--        htp.p('<TITLE>'||fnd_message.get_string('QA', 'QA_SS_VQR')||'</TITLE>');
--        htp.p('<HEAD>');
--        htp.p('<LINK REL="STYLESHEET" HREF="/OA_HTML/'
--		||l_language_code||'/POSSTYLE.css">');
--
--
--        htp.p('<script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
--        htp.p('</script>');
--        htp.p('<script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
--        htp.p('</script>');
--        htp.p('<script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
--        htp.p('</script>');
--
--        js.scriptOpen;
--        pos_global_vars_sv.InitializeMessageArray;
--        js.scriptClose;
--        htp.p('</HEAD>');
--
--	toolbar_heading := fnd_message.get_string('QA', 'QA_SS_VQR');
--	toolbar_heading := wfa_html.conv_special_url_chars(toolbar_heading);
--
--        htp.p('<frameset rows="50,*,40" border=0>');
--        htp.p('<frame src="pos_toolbar_sv.PaintToolbar?p_title='||toolbar_heading||'"
--                name=toolbar
--                marginwidth=6
--                marginheight=2
--                scrolling=no>');
--        htp.p('<frameset cols="3,*,3" border=0>');
--        htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
--                name=borderLeft
--                marginwidth=0
--                marginheight=0
--                scrolling=no>');
--
--	l_plan_name := wfa_html.conv_special_url_chars(l_plan_name);
--        htp.p('<frameset rows="30,*,5" border=0>');
--        htp.p('<frame src="pos_upper_banner_sv.PaintUpperBanner?p_product=QA'||'&'||'p_title='
--		|| l_plan_name || '"
--                name=upperbanner
--                marginwidth=0
--                marginheight=0
--                scrolling=no>');
--
--	if (ss_where_clause is not null) then
--	ss_w_c := wfa_html.conv_special_url_chars(ss_where_clause);
--	end if;
--
--        htp.p('<frame src="qa_ss_core.VQR?plan_id_i='||plan_id_i
--				||'&'
--				||'ss_where_clause='||ss_w_c||'"
--                name=content
--                marginwidth=0
--                marginheight=0
--                scrolling=yes>');
--
--        htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSLWBAN.htm"
--                name=lowerbanner
--                marginwidth=0
--                marginheight=0
--                scrolling=no>');
--
--         htp.p('</frameset>');
--         htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
--                name=borderRight
--                marginwidth=0
--                marginheight=0
--                scrolling=no>');
--         htp.p('</frameset>');
--          htp.p('<frame src="/OA_HTML/'||l_language_code||'/POSBLBOR.htm"
--                name=bottomregion
--                marginwidth=0
--                marginheight=0
--                scrolling=no>');
--          htp.p('</frameset>');
--          htp.p('</HTML>');
--
--
--
--    end if; -- end icx validate session

       NULL;
--EXCEPTION
--    WHEN OTHERS THEN
--	IF plan_name_cur%ISOPEN THEN
--		CLOSE plan_name_cur;
--	END IF;
--        htp.p('Exception in QA_SS_CORE.VQR_Frames');
--        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END Vqr_Frames;
-----------------------------------------------------------------------------------------------------
procedure draw_html_button(src IN VARCHAR2 DEFAULT NULL,
                            txt IN VARCHAR2 DEFAULT NULL)

-- in the above, src is the javascript and txt is the button label
-- Also, look at pos_asn_search_pkg.button (file POSASNSB.pls)
-- written by david chan (dfkchan) of PO team
IS

BEGIN
    htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src || '"><font class=button>'|| txt || '</font></a></td>
          </tr>
          <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
          <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
         </table>
');


EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in QA_SS_CORE.Draw_html_button');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');

END draw_html_button;
-----------------------------------------------------------------------------------------------------
procedure call_workflow(x_buyer_id IN NUMBER DEFAULT NULL,
                        x_source_id IN NUMBER DEFAULT NULL,
                        x_plan_id IN NUMBER DEFAULT NULL,
                        x_item_id IN NUMBER DEFAULT NULL,
                        x_po_header_id IN NUMBER DEFAULT NULL)
IS

BEGIN
    htp.p(fnd_message.get_string('QA', 'QA_SS_NOTIFY_SENT'));
    -- Call Revathy's package below
    qa_ss_import_wf.start_buyer_notification(x_buyer_id ,
                                              x_source_id ,
                                              x_plan_id ,
                                              x_item_id ,
                                              x_po_header_id );

EXCEPTION
    WHEN OTHERS THEN
        htp.p('Exception in QA_SS_CORE.Call_Workflow');
        htp.p('<STRONG><FONT COLOR="#FF0000">'||SQLERRM||'</FONT></STRONG>');
END call_workflow;
-----------------------------------------------------------------------------------------------------
function is_plan_applicable ( Pid IN NUMBER,
			      Txn_Num IN NUMBER default null,
			      PK1 IN VARCHAR2 default null,
			      PK2 IN VARCHAR2 default null,
			      PK3 IN VARCHAR2 default null,
			      PK4 IN VARCHAR2 default null,
			      PK5 IN VARCHAR2 default null,
			      PK6 IN VARCHAR2 default null,
			      PK7 IN VARCHAR2 default null,
			      PK8 IN VARCHAR2 default null,
			      PK9 IN VARCHAR2 default null,
			      PK10 IN VARCHAR2 default null,
			      Txn_Name IN VARCHAR2 default null)
Return VARCHAR2
IS
	Ctx qa_ss_const.Ctx_Table;
		 -- Ctx_Table type is declared in pkg spec
        Prompt_Arr qa_ss_const.var30_table;
	lov_arr qa_ss_const.bool_table;
	disp_len_arr qa_ss_const.num_table;
	dv_arr qa_ss_const.var150_table;  -- for Default Value
        charid_array qa_ss_const.num_table;
        names_array qa_ss_const.var30_table;

	no_of_cols NUMBER := 0;
	plan_name_i qa_plans.name%TYPE := NULL;
	l_language_code varchar2(30);
	it_name VARCHAR2(20);
	de_name VARCHAR2(20); -- dependent element name
	Name VARCHAR2(2000);
	char_name_i qa_chars.name%TYPE;
	item_name VARCHAR2(30) := NULL;
	l_Po_Agent_Id NUMBER := NULL;
        l_User_Id NUMBER := NULL;
        l_Item_Id NUMBER := NULL;
        l_Po_Header_Id NUMBER := NULL;
        l_Wip_Entity_Type NUMBER := NULL;
        l_Wip_Rep_Sch_Id NUMBER := NULL;
        l_Po_Release_Id NUMBER := NULL;
        l_Po_Line_Id NUMBER := NULL;
        l_Line_Location_Id NUMBER := NULL;
        l_Po_Distribution_Id NUMBER := NULL;
        l_Wip_Entity_Id NUMBER := NULL;
        l_Wip_Line_Id NUMBER := NULL;
        l_Po_Shipment_Id NUMBER := NULL;
	l_Organization_Id NUMBER := NULL;

	out_category_value VARCHAR2(1000) := NULL;
	out_category_id NUMBER := NULL;

        temp_pid NUMBER := NULL;
	temp_plan_txn_id NUMBER := NULL;
        chk VARCHAR2(1);
	CURSOR plan_tx_cur IS
		SELECT qpt.plan_id, qpt.plan_transaction_id
		FROM QA_PLAN_TRANSACTIONS QPT
		Where qpt.plan_id = Pid
		and qpt.transaction_number = Txn_Num;

	--
	--this cursor finds if item category is used as
	--a collection trigger for this plan txn
	--
	--CURSOR is_item_cat_cur (c_plan_txn_id IN NUMBER)
	--IS
		--SELECT 1
		--from qa_plan_collection_triggers qpct
		--where qpct.plan_transaction_id = c_plan_txn_id
		--and qpct.collection_trigger_id = 11;
	--collection trigger id 11 is item category

BEGIN
	-- SS OM transaction is not a regular txn
	-- Hence some special logic
	IF (Txn_Name = 'OMHEADER') THEN
		chk:= qa_ss_om.is_om_header_plan_applicable(Pid, PK1);
		RETURN chk;
	ELSIF (Txn_Name = 'OMLINES') THEN
		chk:= qa_ss_om.is_om_lines_plan_applicable(Pid,PK1,PK3);
		RETURN chk;
	END IF;

	-- Below stmts executed only if txn Not OM related
	OPEN plan_tx_cur;
	FETCH plan_tx_cur INTO temp_pid, temp_plan_txn_id;
	IF plan_tx_cur%NOTFOUND
	Then
		Return 'N';
	END IF;
	CLOSE plan_tx_cur;

	qa_ss_core.Default_In_Values
	(Ctx, Txn_Num, PK1, PK2, PK3, PK4,
	 PK5, PK6, PK7, PK8, PK9, PK10,
	 l_Po_Agent_Id, l_Item_Id, l_Po_Header_Id,
         l_Wip_Entity_Type, l_Wip_Rep_Sch_Id, l_Po_Release_Id,
	 l_Po_Line_Id, l_Line_Location_Id, l_Po_Distribution_Id,
         l_Wip_Entity_Id, l_Wip_Line_Id, l_Po_Shipment_Id,
	 l_Organization_Id  );

	--enhancement 2004914 Item Category
	--for family pack H Sep 21, 2001
	if (Txn_Num = 100 or Txn_Num = 110 ) then

		        get_item_category_val (
			p_org_id => l_Organization_Id,
			p_item_id => l_Item_Id,
			x_category_val => out_category_value,
			x_category_id => out_category_id);

		--if for some reason, the procedure
		--cannot find any category for the given item
		--due to QA:Item Category Set Profile being
		--incorrectly set, or any other reason, then
		--out_category_value will have NULL value

		Ctx(qa_ss_const.item_category) := out_category_value;

	end if;

	 chk:= check_plan_for_applicability(Ctx, Txn_Num, l_Organization_Id, pid);
         RETURN chk;

END is_plan_applicable;

-------------------------------------------------------------

function is_plan_applicable_for_osp (
    Pid IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_job_name IN VARCHAR2 DEFAULT NULL,
    p_from_op_seq_num IN VARCHAR2 DEFAULT NULL,
    p_vendor_name IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_production_line IN VARCHAR2 DEFAULT NULL,
    p_organization_id IN NUMBER DEFAULT NULL)
Return VARCHAR2
IS
	Ctx qa_ss_const.Ctx_Table;
		 -- Ctx_Table type is declared in pkg spec
        Prompt_Arr qa_ss_const.var30_table;
	lov_arr qa_ss_const.bool_table;
	disp_len_arr qa_ss_const.num_table;
	dv_arr qa_ss_const.var150_table;  -- for Default Value
        charid_array qa_ss_const.num_table;
        names_array qa_ss_const.var30_table;

	no_of_cols NUMBER := 0;
	plan_name_i qa_plans.name%TYPE := NULL;
	l_language_code varchar2(30);
	it_name VARCHAR2(20);
	de_name VARCHAR2(20); -- dependent element name
	Name VARCHAR2(2000);
	char_name_i qa_chars.name%TYPE;
	item_name VARCHAR2(30) := NULL;
	l_Po_Agent_Id NUMBER := NULL;
        l_User_Id NUMBER := NULL;
        l_Item_Id NUMBER := NULL;
        l_Po_Header_Id NUMBER := NULL;
        l_Wip_Entity_Type NUMBER := NULL;
        l_Wip_Rep_Sch_Id NUMBER := NULL;
        l_Po_Release_Id NUMBER := NULL;
        l_Po_Line_Id NUMBER := NULL;
        l_Line_Location_Id NUMBER := NULL;
        l_Po_Distribution_Id NUMBER := NULL;
        l_Wip_Entity_Id NUMBER := NULL;
        l_Wip_Line_Id NUMBER := NULL;
        l_Po_Shipment_Id NUMBER := NULL;
	l_Organization_Id NUMBER := NULL;

        temp_pid NUMBER := NULL;
        chk VARCHAR2(1);
	CURSOR plan_tx_cur IS
		SELECT qpt.plan_id
		FROM QA_PLAN_TRANSACTIONS QPT
		Where qpt.plan_id = Pid
		and qpt.transaction_number = 100;

BEGIN
	OPEN plan_tx_cur;
	FETCH plan_tx_cur INTO temp_pid;
	IF plan_tx_cur%NOTFOUND
	Then
		Return 'N';
	END IF;
	CLOSE plan_tx_cur;

    Ctx.delete();

    Ctx(qa_ss_const.item) := p_item;
    Ctx(qa_ss_const.revision) := p_revision;
    Ctx(qa_ss_const.job_name) := p_job_name;
    Ctx(qa_ss_const.from_op_seq_num) := p_from_op_seq_num;
    Ctx(qa_ss_const.vendor_name) := p_vendor_name;
    Ctx(qa_ss_const.po_number) := p_po_number;
    Ctx(qa_ss_const.ordered_quantity) := p_ordered_quantity;
    Ctx(qa_ss_const.vendor_item_number) := p_vendor_item_number;
    Ctx(qa_ss_const.vendor_item_number) := p_po_release_num;
    Ctx(qa_ss_const.po_release_num) := p_po_release_num;
    Ctx(qa_ss_const.uom_name) := p_uom_name;
    Ctx(qa_ss_const.production_line) := p_production_line;

    l_organization_id := p_organization_id;

	 chk:= check_plan_for_applicability(Ctx, 100, l_Organization_Id, pid);
         RETURN chk;

END is_plan_applicable_for_osp;

-------------------------------------------------------------
FUNCTION is_plan_applicable_for_ship (
    Pid IN NUMBER,
    p_item IN VARCHAR2 DEFAULT NULL,
    p_item_category IN VARCHAR2 DEFAULT NULL,
    p_revision IN VARCHAR2 DEFAULT NULL,
    p_supplier IN VARCHAR2 DEFAULT NULL,
    p_po_number IN VARCHAR2 DEFAULT NULL,
    p_po_line_num IN VARCHAR2 DEFAULT NULL,
    p_po_shipment_num IN VARCHAR2 DEFAULT NULL,
    p_ship_to IN VARCHAR2 DEFAULT NULL,
    p_ordered_quantity IN VARCHAR2 DEFAULT NULL,
    p_vendor_item_number IN VARCHAR2 DEFAULT NULL,
    p_po_release_num IN VARCHAR2 DEFAULT NULL,
    p_uom_name IN VARCHAR2 DEFAULT NULL,
    p_supplier_site IN VARCHAR2 DEFAULT NULL,
    p_ship_to_location IN VARCHAR2 DEFAULT NULL,
    p_organization_id IN NUMBER DEFAULT NULL)
    RETURN VARCHAR2
IS
	Ctx qa_ss_const.Ctx_Table;
		 -- Ctx_Table type is declared in pkg spec
        Prompt_Arr qa_ss_const.var30_table;
	lov_arr qa_ss_const.bool_table;
	disp_len_arr qa_ss_const.num_table;
	dv_arr qa_ss_const.var150_table;  -- for Default Value
        charid_array qa_ss_const.num_table;
        names_array qa_ss_const.var30_table;

	no_of_cols NUMBER := 0;
	plan_name_i qa_plans.name%TYPE := NULL;
	l_language_code varchar2(30);
	it_name VARCHAR2(20);
	de_name VARCHAR2(20); -- dependent element name
	Name VARCHAR2(2000);
	char_name_i qa_chars.name%TYPE;
	item_name VARCHAR2(30) := NULL;
	l_Po_Agent_Id NUMBER := NULL;
        l_User_Id NUMBER := NULL;
        l_Item_Id NUMBER := NULL;
        l_Po_Header_Id NUMBER := NULL;
        l_Wip_Entity_Type NUMBER := NULL;
        l_Wip_Rep_Sch_Id NUMBER := NULL;
        l_Po_Release_Id NUMBER := NULL;
        l_Po_Line_Id NUMBER := NULL;
        l_Line_Location_Id NUMBER := NULL;
        l_Po_Distribution_Id NUMBER := NULL;
        l_Wip_Entity_Id NUMBER := NULL;
        l_Wip_Line_Id NUMBER := NULL;
        l_Po_Shipment_Id NUMBER := NULL;
	l_Organization_Id NUMBER := NULL;

        temp_pid NUMBER := NULL;
        chk VARCHAR2(1);
	CURSOR plan_tx_cur IS
		SELECT qpt.plan_id
		FROM QA_PLAN_TRANSACTIONS QPT
		Where qpt.plan_id = Pid
		and qpt.transaction_number = 110;

BEGIN
	OPEN plan_tx_cur;
	FETCH plan_tx_cur INTO temp_pid;
	IF plan_tx_cur%NOTFOUND
	Then
		Return 'N';
	END IF;
	CLOSE plan_tx_cur;

    Ctx.delete();

    Ctx(qa_ss_const.item) := p_item;
    Ctx(qa_ss_const.item_category) := p_item_category;
    Ctx(qa_ss_const.revision) := p_revision;
    Ctx(qa_ss_const.vendor_name) := p_supplier;
    Ctx(qa_ss_const.po_number) := p_po_number;
    Ctx(qa_ss_const.po_line_num) := p_po_line_num;
    Ctx(qa_ss_const.po_shipment_num) := p_po_shipment_num;
    Ctx(qa_ss_const.ship_to) := p_ship_to;
    Ctx(qa_ss_const.ordered_quantity) := p_ordered_quantity;
    Ctx(qa_ss_const.vendor_item_number) := p_vendor_item_number;
    Ctx(qa_ss_const.po_release_num) := p_po_release_num;
    Ctx(qa_ss_const.uom_name) := p_uom_name;
    Ctx(qa_ss_const.vendor_site_code) := p_supplier_site;
    Ctx(qa_ss_const.ship_to_location) := p_ship_to_location;


    l_organization_id := p_organization_id;

	 chk:= check_plan_for_applicability(Ctx, 110, l_Organization_Id, pid);
         RETURN chk;

END is_plan_applicable_for_ship;

-------------------------------------------------------------


function check_plan_for_applicability ( Ctx IN qa_ss_const.Ctx_Table,
				x_Txn_Number IN NUMBER,
				x_organization_id IN NUMBER,
				x_Pid IN NUMBER)
RETURN VARCHAR2

IS

Cursor coll_trigg_cur is
	SELECT qpt.Plan_transaction_id,
		qpt.Plan_id,
		qc.char_id,
        qc.dependent_char_id,
		qc.datatype,
		qpct.Operator,
		qpct.Low_Value,
		qpct.High_Value
	FROM qa_plan_collection_triggers qpct,
		qa_plan_transactions qpt,
		qa_plans qp,
        qa_chars qc,
		qa_txn_collection_triggers qtct
	WHERE qp.Plan_ID = x_Pid
	AND qpt.Plan_ID = qp.Plan_ID
	AND qpct.Plan_Transaction_ID(+) = qpt.Plan_Transaction_ID
        AND qpct.Collection_Trigger_ID = qtct.Collection_Trigger_ID(+)
        AND qpct.Collection_Trigger_ID = qc.char_id(+)
	AND qpt.TRANSACTION_NUMBER = x_txn_number
        AND qtct.TRANSACTION_NUMBER(+) = x_txn_number
        AND qp.ORGANIZATION_ID = x_organization_id
        AND qpt.enabled_flag = 1
ORDER BY qpt.plan_transaction_id;

Type Coll_Trigg_Type is TABLE of coll_trigg_cur%ROWTYPE INDEX BY BINARY_INTEGER;
Coll_Trigg_Tab  Coll_Trigg_Type;

plan_is_applicable BOOLEAN;
counter INTEGER;
i INTEGER := 1;

l_rowcount INTEGER;

l_datatype NUMBER;
l_operator NUMBER;
l_low_char VARCHAR2(150);
l_high_char VARCHAR2(150);
l_low_number NUMBER;
l_high_number NUMBER;
l_low_date DATE;
l_high_date DATE;
l_value_char VARCHAR2(150);
l_value_number NUMBER;
l_value_date DATE;

l_plan_id	NUMBER;
l_old_plan_id NUMBER;

l_plan_txn_id NUMBER ;
l_old_plan_txn_id NUMBER ;


l_char_id NUMBER;
l_dep_char_id NUMBER;
pid_count NUMBER := 0;
atleast_one BOOLEAN;
    -- All variables beginning with l_ are local variables
BEGIN

    atleast_one := FALSE;
    counter := 1;
	For ct_rec in coll_trigg_cur
	loop
		coll_trigg_tab(counter) := ct_rec;
		counter := counter + 1;
	end loop;

	l_rowcount := coll_trigg_tab.count;

    if (l_rowcount < 1) Then
        return 'N'; -- no plans applicable
    end if;

    l_plan_txn_id := coll_trigg_tab(1).plan_transaction_id;

        -- The variable i has been  initialized to 1

      WHILE ( i <= l_rowcount)
        LOOP
            l_old_plan_txn_id := l_plan_txn_id;
            plan_is_applicable := TRUE; -- start with this assumption

            WHILE (l_plan_txn_id = l_old_plan_txn_id) AND (i <= l_rowcount)
            LOOP
                IF (plan_is_applicable = TRUE)
                THEN
                        l_operator := coll_trigg_tab(i).Operator;
                        l_datatype := coll_trigg_tab(i).Datatype;
                        l_char_id := coll_trigg_tab(i).char_id;
                        IF (l_operator is NULL) AND (l_datatype is NULL)
                        THEN
                            null;
                                -- null collection trigger. Plan applies
                        ELSE
                            -- WATCH OUT FOR EXCEPTIONS while
                            -- accessing Ctx table below
                                IF (qltcompb.compare( Ctx(l_char_id),
                                                  l_operator,
                                                  coll_trigg_tab(i).Low_value,
                                                  coll_trigg_tab(i).High_Value,
                                                  l_datatype)  )
                                    -- above is a overloaded call
                                THEN
                                        plan_is_applicable := TRUE;
                                ELSE
                                        plan_is_applicable := FALSE;
                                END IF; --end qltcompb
                         END IF;  -- end l_operator and l_datatype null
               END IF; -- end Check plan applicable is true

                i := i+1;
                IF (i <= l_rowcount) THEN
                        l_plan_txn_id := coll_trigg_tab(i).plan_transaction_id;
                END IF;
             END LOOP; -- end inner while loop
             IF (plan_is_applicable = TRUE) THEN
                    RETURN 'Y';
	     END IF;
                        -- if flag is not 2, then keep continuing

      END LOOP; -- end outer while loop

	       RETURN 'N';

END;

function get_rel_num (po_rel_id IN NUMBER)
Return NUMBER
IS
	l_rel_num NUMBER := NULL;

	CURSOR rel_num_cur IS
	SELECT Release_Num
	FROM Po_Releases_All
	WHERE Po_Release_Id = po_rel_id;

BEGIN
	IF ( po_rel_id is NOT Null) Then
		Open rel_num_cur;
		Fetch rel_num_cur INTO l_rel_num;
		Close rel_num_cur;
	END IF;
	Return l_rel_num;
END;


function get_buyer_id (po_hdr_id IN Number,
			po_rel_id IN Number)
Return  NUMBER
IS
	l_buyer_id NUMBER := NULL;

	CURSOR buyer1_cur IS
	Select AGENT_ID
	From 	PO_HEADERS_ALL
	Where	PO_HEADER_ID = po_hdr_id;

	CURSOR buyer2_cur IS
	Select AGENT_ID
	From	PO_RELEASES_ALL
	Where	PO_RELEASE_ID = po_rel_id;

BEGIN
	IF (po_rel_id is NOT NULL) THEN
		OPEN buyer2_cur;
		FETCH buyer2_cur INTO l_buyer_id;
		CLOSE buyer2_cur;
	ELSIF (po_hdr_id is NOT NULL) THEN
		OPEN buyer1_cur;
		FETCH buyer1_cur INTO l_buyer_id;
		CLOSE buyer1_cur;
	END IF;

	Return l_buyer_id;
END;

function is_context_element (element_id IN NUMBER, txn_number IN NUMBER)
RETURN VARCHAR2
	-- This is a wrapper to return varchar2 so it can be made
	-- use of in sql statement. Boolean wont work.
	-- 'Y' or 'N' returned
	-- look also at qltakmpb.plb function context_element
IS
    result BOOLEAN;
    dummy NUMBER;

    CURSOR c IS
        SELECT 1
        FROM   qa_txn_collection_triggers qtct
        WHERE  qtct.transaction_number = txn_number
        AND    qtct.collection_trigger_id = element_id;

BEGIN
    -- This function determines if collection element is a context element
    -- given a transaction number.

    OPEN c;
    FETCH c INTO dummy;
    result := c%FOUND;
    CLOSE c;

    if (result)
    then
	    Return 'Y';
    else
	    Return 'N';
    end if;
end; -- end function is_context_element
----------------------------------------------------------
function Check_Valid_Job (X_Wip_Entity_Id IN NUMBER)
	Return VARCHAR2
IS
	l_ent_type NUMBER;
	l_dummy_var NUMBER;
	valid_ok BOOLEAN := TRUE;
	CURSOR we_type_cur IS
		SELECT entity_type
		FROM WIP_ENTITIES
		WHERE WIP_ENTITY_ID = X_Wip_Entity_Id;

 -- #2382432
 -- Changed the view to WIP_DISCRETE_JOBS_ALL_V instead of
 -- earlier wip_open_discrete_jobs_val_v
 -- rkunchal Sun Jun 30 22:59:11 PDT 2002

	CURSOR wdj_open_val_cur IS
		SELECT wip_entity_id
		FROM WIP_DISCRETE_JOBS_ALL_V
		WHERE WIP_ENTITY_ID = X_Wip_Entity_Id;

BEGIN
	OPEN we_type_cur;
	FETCH we_type_cur INTO l_ent_type;
	CLOSE we_type_cur;
	IF (l_ent_type = 3) THEN -- closed discrete job
		valid_ok := FALSE; -- not valid for eqr
	END IF;
	IF (l_ent_type = 1) THEN -- open disc job;need more eval
		OPEN wdj_open_val_cur;
		FETCH wdj_open_val_cur INTO l_dummy_var;
		IF wdj_open_val_cur%FOUND THEN
			valid_ok := TRUE;
		ELSE
			valid_ok := FALSE;
			-- set to FALSE only if l_ent_type = 1
			-- AND not in WIP_OPEN_DISCRETE_JOBS_VAL_V
		END IF;
		CLOSE wdj_open_val_cur;
	END IF;
	IF (valid_ok) THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;

END Check_Valid_Job;


end qa_ss_core;


/
