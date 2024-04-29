--------------------------------------------------------
--  DDL for Package Body QP_MAINTAIN_DENORMALIZED_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MAINTAIN_DENORMALIZED_DATA" AS
/*$Header: QPXDENOB.pls 120.8.12010000.7 2009/07/28 10:24:35 dnema ship $ */

--added for bug 5237249
G_LIST_HEADER_ID NUMBER;
G_LIST_HEADER_ID_HIGH NUMBER;
G_UPDATE_TYPE VARCHAR2(50);

/**********************added these debug procedures as a part of bug fix for 2181164**********************/

----procedure to write the log messages
Procedure put_line(p_mesg_text        IN  varchar2)
IS
BEGIN
	IF nvl(fnd_profile.value('CONC_REQUEST_ID'),0) <> 0 THEN
		fnd_file.put_line(FND_FILE.LOG,p_mesg_text);
        END IF;
END put_line;

/**************************end of changes bug fix 2181164****************************************************/


--hvop
Procedure Set_HVOP_Pricing (x_return_status OUT NOCOPY VARCHAR2,
                            x_return_status_text OUT NOCOPY VARCHAR2)
Is

Cursor l_basic_modifiers_cur Is
SELECT 'N' FROM dual WHERE
       EXISTS(
              SELECT 'Y'
              FROM    qp_list_headers_b qh,
                      qp_list_lines ql
              WHERE       qh.list_type_code = 'PRO'
                      and qh.active_flag = 'Y'
                      and ql.list_header_id = qh.list_header_id
                      and ql.list_line_type_code in ('PRG','IUE','TSN','CIE')
                      and rownum = 1
            );

Cursor l_limits_cur IS
        SELECT  'N'
        FROM qp_list_headers_b qh
        WHERE qh.active_flag = 'Y'
        and qh.list_type_code in ('PRO','DLT','SLT','DEL','CHARGES')
        and exists (select 'Y'
                from qp_limits qlim
                where qlim.list_header_id = qh.list_header_id)
        and rownum = 1;
l_HVOP_Possible VARCHAR2(1) := 'Y';
dummy BOOLEAN;

BEGIN


If QP_Code_Control.Get_Code_Release_Level > '110509'
Then
    If QP_Java_Engine_Util_PUB.Java_Engine_Running = 'Y'
    Then
	Open l_basic_modifiers_cur;
	Fetch l_basic_modifiers_cur Into l_HVOP_Possible;
	Close l_basic_modifiers_cur;

	If l_HVOP_Possible = 'Y' Then
          Open l_limits_cur;
	  Fetch l_limits_cur Into l_HVOP_Possible;
	  Close l_limits_cur;
	End If;
    Else
    	l_HVOP_Possible := 'N';
    End If;

    dummy := fnd_profile.save ( x_name => 'QP_HVOP_PRICING_SETUP',X_VALUE => l_HVOP_Possible, X_LEVEL_NAME => 'SITE');

End If; --Code Control

--		  commit; --Commented because of Bug #3548384

EXCEPTION
	When OTHERS Then
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_return_status_text := 'Exception in Set_HVOP_Pricing: '||SQLERRM;

END Set_HVOP_Pricing;
--hvop

procedure update_adv_mod_products(x_return_status OUT NOCOPY VARCHAR2,
                                 x_return_status_text OUT NOCOPY VARCHAR2) IS

BEGIN
--this procedure is called to populate the product dependencies for
--line group based and OID/PRG based discounts to identify which lines
--need to be passed to the pricing engine

--this same operation is done in the delayed request API for delayed requests
--done from the forms. In case any bug fixes are done to this, the same
--needs to be propagated to QPXUREQB.pls procedures
--update_changed_lines_add/del/act/ph

if G_UPDATE_TYPE <> 'BATCH_ADV_MOD_PRODUCTS' then
--added for bug 5237249
--delete should not happen for parallel threads from qpxsourc.sql
--otherwise it will delete the previous worker's rows
--moved the delete to qpxsourc.sql
  delete from qp_adv_mod_products;
end if;

insert into qp_adv_mod_products
(pricing_phase_id, product_attribute, product_attr_value)
(select /*+ ORDERED USE_NL(qlh) */ ql.pricing_phase_id, 'PRICING_ATTRIBUTE3', 'ALL_ITEMS'
from qp_list_lines ql, qp_list_headers_b qlh
where ql.qualification_ind = 0
and ql.pricing_phase_id <> 1
and ql.modifier_level_code = 'LINEGROUP'
--added for bug 5237249
and ((G_LIST_HEADER_ID IS NOT null
and G_LIST_HEADER_ID_HIGH IS NOT null
and qlh.list_header_id between G_LIST_HEADER_ID and G_LIST_HEADER_ID_HIGH)
or (G_LIST_HEADER_ID IS NULL)
or (G_LIST_HEADER_ID_HIGH IS NULL))
and not exists (select 'Y' from qp_pricing_attributes qpa
	where qpa.list_line_id = ql.list_line_id)
and qlh.list_header_id = ql.list_header_id
and qlh.active_flag = 'Y'
and rownum =1);

--Removed hints from the sql to make it more cost effective.
insert into qp_adv_mod_products
(pricing_phase_id, product_attribute, product_attr_value)
(select
distinct ql.pricing_phase_id, qpa.product_attribute, qpa.product_attr_value
from qp_rltd_modifiers rltd, qp_list_lines ql, qp_list_headers_b qlh
,qp_pricing_attributes qpa
where rltd.rltd_modifier_grp_type = 'BENEFIT'
and ql.list_line_id = rltd.to_rltd_modifier_id
--and ql.list_line_type_code = 'DIS'
and qlh.list_header_id = ql.list_header_id
--added for bug 5237249
and ((G_LIST_HEADER_ID IS NOT null
and G_LIST_HEADER_ID_HIGH IS NOT null
and qlh.list_header_id between G_LIST_HEADER_ID and G_LIST_HEADER_ID_HIGH)
or (G_LIST_HEADER_ID IS NULL)
or (G_LIST_HEADER_ID_HIGH IS NULL))
and qlh.active_flag = 'Y'
--and qlh.list_type_code in ( 'DEL', 'PRO')
and qpa.list_line_id = ql.list_line_id
and not exists (select 'Y' from qp_adv_mod_products item
        where item.pricing_phase_id = qpa.pricing_phase_id
        and item.product_attribute = qpa.product_attribute
        and item.product_attr_value = qpa.product_attr_value)
UNION
select
distinct ql.pricing_phase_id, qpa.product_attribute, qpa.product_attr_value
from qp_list_lines ql
, qp_list_headers_b qlh
, qp_pricing_attributes qpa
where ql.pricing_phase_id > 1
and ql.qualification_ind > 0
and ql.list_line_type_code in ('OID', 'PRG', 'RLTD')
and qpa.list_line_id = ql.list_line_id
and qlh.list_header_id = ql.list_header_id
and qlh.active_flag = 'Y'
--added for bug 5237249
and ((G_LIST_HEADER_ID IS NOT null
and G_LIST_HEADER_ID_HIGH IS NOT null
and qlh.list_header_id between G_LIST_HEADER_ID and G_LIST_HEADER_ID_HIGH)
or (G_LIST_HEADER_ID IS NULL)
or (G_LIST_HEADER_ID_HIGH IS NULL))
and qlh.list_type_code in ('DLT', 'SLT', 'DEL', 'PRO', 'CHARGES')
and not exists (select 'Y' from qp_adv_mod_products item
        where item.pricing_phase_id = qpa.pricing_phase_id
        and item.product_attribute = qpa.product_attribute
        and item.product_attr_value = qpa.product_attr_value)
UNION
select
distinct ql.pricing_phase_id, qpa.product_attribute, qpa.product_attr_value
from qp_list_lines ql
, qp_list_headers_b qlh
, qp_pricing_attributes qpa
where ql.modifier_level_code = 'LINEGROUP'
and ql.pricing_phase_id > 1
and qpa.list_line_id = ql.list_line_id
and qlh.list_header_id = ql.list_header_id
and qlh.active_flag = 'Y'
--added for bug 5237249
and ((G_LIST_HEADER_ID IS NOT null
and G_LIST_HEADER_ID_HIGH IS NOT null
and qlh.list_header_id between G_LIST_HEADER_ID and G_LIST_HEADER_ID_HIGH)
or (G_LIST_HEADER_ID IS NULL)
or (G_LIST_HEADER_ID_HIGH IS NULL))
and qlh.list_type_code in ('DLT', 'SLT', 'DEL', 'PRO', 'CHARGES')
and not exists (select 'Y' from qp_adv_mod_products item
        where item.pricing_phase_id = qpa.pricing_phase_id
        and item.product_attribute = qpa.product_attribute
        and item.product_attr_value = qpa.product_attr_value));

commit;
EXCEPTION
When OTHERS Then
x_return_status := FND_API.G_RET_STS_ERROR;
x_return_status_text := 'update_adv_mod_products exception '||SQLERRM;
END update_adv_mod_products;

procedure update_pricing_phases(p_update_type IN VARCHAR2
				, p_pricing_phase_id IN NUMBER
                                , p_automatic_flag IN VARCHAR2
 				, p_count NUMBER
                                , p_call_from NUMBER
				, x_return_status OUT NOCOPY VARCHAR2
				, x_return_status_text OUT NOCOPY VARCHAR2) IS

/* Changed the cursor below for the bug#2572053 */
CURSOR l_basic_modifiers_cur IS
       SELECT 'Y' FROM DUAL WHERE
       EXISTS(
              SELECT 'Y'
              FROM    qp_list_headers_b qh,
                      qp_list_lines ql
              WHERE       qh.list_type_code = 'PRO'
                      and qh.active_flag = 'Y'
                      and ql.list_header_id = qh.list_header_id
                      and ql.list_line_type_code in ('OID','PRG','IUE','TSN','CIE')
                      and rownum = 1
            );

CURSOR l_limits_exist_cur IS
	SELECT 'Y'
	FROM qp_list_headers_b qh
	WHERE qh.active_flag = 'Y'
	and qh.list_type_code in ('PRO','DLT','SLT','DEL','CHARGES')
	and exists (select 'Y'
		from qp_limits qlim
		where qlim.list_header_id = qh.list_header_id)
	and rownum = 1;

-- Essilor Fix bug 2789138
-- Commented for bug#2894244
CURSOR l_phase_cur(p_phase_id NUMBER) IS
    select pricing_phase_id
    from qp_pricing_phases
    where pricing_phase_id = nvl(p_phase_id, pricing_phase_id);

-- Added the following variables for bug#2572053
--l_rltd_exists VARCHAR2(1) := 'N';
--l_oid_exists  VARCHAR2(1) := 'N';
--l_line_group_exists  VARCHAR2(1) := 'N';
--l_freight_exists  VARCHAR2(1) := 'N';

-- Essilor Fix bug 2789138
-- Commented for bug#2894244
 l_automatic_exists  VARCHAR2(1) := 'N';
 l_manual_exists  VARCHAR2(1) := 'N';
 l_manual_modifier_flag VARCHAR2(1);

l_limits_exist VARCHAR2(1) := 'N';
l_basic_modifiers_exist VARCHAR2(1) := 'N';
l_profile_val varchar2(300);
Phase_Exception Exception;
d_manual_modifier_flag varchar2(1);
begin
		IF p_update_type in ('PHASE', 'ALL')
		THEN
		put_line('Begin Pricing Phase Update');
		END IF;
-- bug 3448292
           -- Changed the update statement to look for pricing_phase_id other than 1, bug 2981629
           -- also rearranged the tables and changed the optimizer hint
                       /*update qp_pricing_phases PH
--at least 1 PRG modifier exists with rltd line
                        set rltd_exists = (
                               select /*+ ordered use_nl(rlt lh) index(ll QP_LIST_LINES_N5) * / 'Y'
                                from qp_list_lines LL, qp_rltd_modifiers RLT, qp_list_headers_b LH
                               where LH.active_flag = 'Y'
                                 and LH.list_type_code = 'PRO'
                                              and LL.pricing_phase_id = PH.pricing_phase_id
                                                and LL.list_header_id = LH.list_header_id
                                                and LL.list_line_id = RLT.from_rltd_modifier_id
                                                and RLT.rltd_modifier_grp_type = 'QUALIFIER'
                                                and LL.list_line_type_code = 'PRG'
                                and rownum = 1)
--atleast 1 modifier of type OID exist
                        , oid_exists = (
                                SELECT /*+ ordered use_nl(lh) index(ll QP_LIST_LINES_N5) * / 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code = 'PRO'
                                and LH.active_flag = 'Y'
                                              and LL.pricing_phase_id = PH.pricing_phase_id
                                              and LL.list_line_type_code = 'OID'
                                              and LL.list_header_id = LH.list_header_id
                                and rownum = 1)
--at least 1 modifier of level line_group exist
                        , line_group_exists = (
                            SELECT /*+ ordered use_nl(lh) index(ll QP_LIST_LINES_N4) * / 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code in ('DLT','DEL','SLT','PRO','CHARGES')
                                and LH.active_flag = 'Y'
                                             and LL.list_header_id = LH.list_header_id
                                               and LL.pricing_phase_id = PH.pricing_phase_id
                                               and LL.modifier_level_code = 'LINEGROUP'
                                and rownum = 1)
--at least 1 freight charge modifier exist
                        , freight_exists = (
                            SELECT /*+ ordered use_nl(lh) index(ll QP_LIST_LINES_N5) * / 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code = 'CHARGES'
                                and LH.active_flag = 'Y'
                                and LL.list_header_id = LH.list_header_id
                                and LL.pricing_phase_id = PH.pricing_phase_id
                                and LL.list_line_type_code = 'FREIGHT_CHARGE'
                                and rownum = 1)
                        where PH.pricing_phase_id = nvl(p_pricing_phase_id,
                                        PH.pricing_phase_id)
                          and ph.pricing_phase_id > 1;
*/
		if (nvl(p_pricing_phase_id,2) > 1)
and (p_call_from is null or p_call_from = 1)then
					   update qp_pricing_phases PH
--at least 1 PRG modifier exists with rltd line
                        --[julin/4698834] removed qp_rltd_modifiers RLT; per bug, needs to be 'Y' if PRG simply exists
                        set rltd_exists = (
                               select 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                               where LH.active_flag = 'Y'
                                 and LH.list_type_code = 'PRO'
                                              and LL.pricing_phase_id = PH.pricing_phase_id
                                                and LL.list_header_id = LH.list_header_id
                                                --and LL.list_line_id = RLT.from_rltd_modifier_id
                                                --and RLT.rltd_modifier_grp_type = 'QUALIFIER'
                                                and LL.list_line_type_code = 'PRG'
                                and rownum = 1)
                        where PH.pricing_phase_id = nvl(p_pricing_phase_id,
                                        PH.pricing_phase_id)
                          and ph.pricing_phase_id > 1;
--atleast 1 modifier of type OID exist
					   update qp_pricing_phases PH
                       set  oid_exists = (
                                SELECT  'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code = 'PRO'
                                and LH.active_flag = 'Y'
                                              and LL.pricing_phase_id = PH.pricing_phase_id
                                              and LL.list_line_type_code = 'OID'
                                              and LL.list_header_id = LH.list_header_id
                                and rownum = 1)
                        where PH.pricing_phase_id = nvl(p_pricing_phase_id,
                                        PH.pricing_phase_id)
                          and ph.pricing_phase_id > 1;
--at least 1 modifier of level line_group exist
					if (nvl(p_pricing_phase_id,3) >2) then
					   update qp_pricing_phases PH
                      set  line_group_exists = (
                            SELECT  /*+ ordered use_nl(lh) index(ll QP_LIST_LINES_N4) */ 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code in ('DLT','DEL','SLT','PRO','CHARGES')
                                and LH.active_flag = 'Y'
                                             and LL.list_header_id = LH.list_header_id
                                               and LL.pricing_phase_id = PH.pricing_phase_id
                                               and LL.modifier_level_code = 'LINEGROUP'
											   and ph.pricing_phase_id >2
                                and rownum = 1)
                        where PH.pricing_phase_id = nvl(p_pricing_phase_id,
                                        PH.pricing_phase_id)
                          and ph.pricing_phase_id > 1;
					end if;
--at least 1 freight charge modifier exist
					   update qp_pricing_phases PH
                        set  freight_exists = (
                            SELECT 'Y'
                                from qp_list_lines LL, qp_list_headers_b LH
                                where LH.list_type_code = 'CHARGES'
                                and LH.active_flag = 'Y'
                                and LL.list_header_id = LH.list_header_id
                                and LL.pricing_phase_id = PH.pricing_phase_id
                                and LL.list_line_type_code = 'FREIGHT_CHARGE'
                                and rownum = 1)
                        where PH.pricing_phase_id = nvl(p_pricing_phase_id,
                                        PH.pricing_phase_id)
                          and ph.pricing_phase_id > 1;
			  		end if;
-- Essilor Fix bug 2789138
-- Fix for 3456907 - added rownum = 1 to the two select's below
--bug 3448292 uncommented the pl-sql part.
                 For I in l_phase_cur(p_pricing_phase_id) LOOP

					if I.pricing_phase_id >1  and
                 (p_call_from is null or p_call_from =2)then -- bug 3509423, look into the cursor value, not parameter

----------------------------fix for bug 3756625
if p_count is not null then
   if p_count > 1 then
     l_automatic_exists :='Y';
     l_manual_exists :='Y';
   end if;
  if p_count = 1 then
   if p_automatic_flag ='Y' then
      l_automatic_exists :='Y';
   else
      l_manual_exists :='Y';
   end if;
  end if;
elsif p_automatic_flag is not null then
 select manual_modifier_flag into d_manual_modifier_flag from qp_pricing_phases
 where pricing_phase_id = I.pricing_phase_id;
 if d_manual_modifier_flag= 'A'  then
 l_automatic_exists :='Y';
elsif d_manual_modifier_flag='M' then
l_manual_exists :='Y';
elsif d_manual_modifier_flag='B' then
l_automatic_exists :='Y';
l_manual_exists :='Y';
else null;
end if;
if p_automatic_flag = 'Y' then
l_automatic_exists :='Y';
else
l_manual_exists :='Y';
end if;
----------------------------------fix for bug 3756625
else


					begin
                         /*
                         select 'Y' into l_automatic_exists
                         from qp_list_lines l, qp_list_headers_b h
                         where l.automatic_flag = 'Y'
                         and   l.pricing_phase_id = I.pricing_phase_id
                         and   l.list_header_id = h.list_header_id
                         and   l.modifier_level_code in ('LINE', 'LINEGROUP', 'ORDER')
                         and   h.active_flag = 'Y'
			 and   rownum = 1;
                         */
                         --fix for sql repository perf bug 3640054
                         select 'Y' into l_automatic_exists from dual
                         where exists (select 1 from qp_list_lines l
                                      where l.automatic_flag = 'Y'
                                      and  l.pricing_phase_id = I.pricing_phase_id
                                      and  exists (select 'x' from qp_list_headers_b h
                                                  where l.list_header_id = h.list_header_id
                                                  and  h.active_flag = 'Y'));
                    exception
                        WHEN no_data_found THEN
                         NULL;
                    end;

                    begin
                         /*
                         select 'Y' into l_manual_exists
                         from qp_list_lines l, qp_list_headers_b h
                         where l.automatic_flag = 'N'
                         and   l.pricing_phase_id = I.pricing_phase_id
                         and   l.list_header_id = h.list_header_id
                         and   l.modifier_level_code in ('LINE', 'LINEGROUP', 'ORDER')
                         and   h.active_flag = 'Y'
			 and   rownum = 1;
                         */
                         --fix for sql repository perf bug 3640054
                         select 'Y' into l_manual_exists from dual
                         where exists (select 1 from qp_list_lines l
                                      where l.automatic_flag = 'N'
                                      and  l.pricing_phase_id = I.pricing_phase_id
                                      and  exists (select 'x' from qp_list_headers_b h
                                                  where l.list_header_id = h.list_header_id
                                                  and  h.active_flag = 'Y'));
                    exception
                        WHEN no_data_found THEN
                         NULL;
                    end;
      end if;
                    IF l_automatic_exists = 'Y' THEN
                       IF l_manual_exists = 'Y' THEN
                          l_manual_modifier_flag := 'B';
                       ELSE
                          l_manual_modifier_flag := 'A';
                       END IF;
                    ELSIF l_manual_exists = 'Y' THEN
                       l_manual_modifier_flag := 'M';
                    END IF;

                    update qp_pricing_phases
                    set    manual_modifier_flag =  l_manual_modifier_flag
                    where pricing_phase_id = I.pricing_phase_id;

                    l_automatic_exists := 'N';
                    l_manual_exists := 'N';
                    l_manual_modifier_flag := NULL;
                 end if;
                 END LOOP;
-- bug 3448292 had to comment out because of high cost involved in SORT and
--CONCATENATE
           --Added for bug#2894244
           -- Changed the update statement to look for pricing_phase_id other than 1, bug 2981629
           -- also rearranged the tables and changed the optimizer hint
/*                update qp_pricing_phases I
                 set    manual_modifier_flag =
                   (select /*+ ordered use_nl(h) index(l QP_LIST_LINES_N5)
                    decode(min(l.automatic_flag)||max(l.automatic_flag),'YY','A','NN','M','B')
                    from qp_list_lines l, qp_list_headers_b h
                    where l.pricing_phase_id = I.pricing_phase_id
                     and  l.list_header_id = h.list_header_id
                     and  h.active_flag = 'Y')
                 where pricing_phase_id = nvl(p_pricing_phase_id, pricing_phase_id)
                   and pricing_phase_id > 1;
*/
		IF p_update_type in ('PHASE', 'ALL')
		THEN
		put_line('End Pricing Phase Update');
		END IF;

--post QP.I, the OM integration code will go thru the performance code path
--in all cases. So profile QP_BASIC_MODIFIERS_SETUP will be set to N always
  IF QP_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN
		OPEN l_basic_modifiers_cur;
		FETCH l_basic_modifiers_cur INTO l_basic_modifiers_exist;
		CLOSE l_basic_modifiers_cur;

		OPEN l_limits_exist_cur;
		FETCH l_limits_exist_cur INTO l_limits_exist;
		CLOSE l_limits_exist_cur;

		IF p_update_type in ('PHASE', 'ALL')
		THEN
		put_line('Completed Update of Profile: limits exist: '||l_limits_exist||' basic modifiers exist: '||l_basic_modifiers_exist);
		END IF;--update_type
  END IF;--QP_CODE_CONTROL.Get_Code_Release_Level

--this was added for QP.H to check if there are only basic modifiers in the
--setup and to setup a profile accordingly. Based on this profile
--OM-QP integration will call new code path if profile is 'Y'
--if there are no limits and no advanced modifiers
--post QP.I, the OM integration code will go thru the performance code path
--in all cases. So profile QP_BASIC_MODIFIERS_SETUP will be set to N always

         IF QP_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN -- Bug 2841107
		IF ((l_limits_exist = 'N')
			and (l_basic_modifiers_exist = 'N'))
		THEN
			IF p_update_type in ('PHASE', 'ALL')
			THEN
			put_line('Completed Update of Profile: limits exist: '||l_limits_exist||' basic modifiers exist: '||l_basic_modifiers_exist);
			END IF;--update_type
			IF (FND_PROFILE.SAVE('QP_BASIC_MODIFIERS_SETUP'
					,'Y','SITE'))--) = FND_API.G_FALSE)
			THEN
				null;
			ELSE
				Raise Phase_Exception;
			END IF;
		ELSE
			IF p_update_type in ('PHASE', 'ALL')
			THEN
			put_line('Completed Update of Profile: limits exist: '||l_limits_exist||' basic modifiers exist: '||l_basic_modifiers_exist);
			END IF;--update_type

			IF (FND_PROFILE.SAVE('QP_BASIC_MODIFIERS_SETUP'
				,'N','SITE'))--) =  FND_API.G_FALSE)
			THEN
				null;
			ELSE
				Raise Phase_Exception;
			END IF;
		END IF;

       -- END IF; --commenting for bug#3798392

		IF p_update_type in ('PHASE', 'ALL', 'BATCH')
		THEN
			commit;
		END IF;

		IF p_update_type in ('PHASE', 'ALL')
		THEN
		FND_PROFILE.GET('QP_BASIC_MODIFIERS_SETUP',l_profile_val);
		put_line('Completed Update of Profile:'||l_profile_val);
		END IF;--update_type
      END IF; --for bug#3798392


EXCEPTION
When Phase_Exception THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_return_status_text := 'QP_DENOB.update_pricing_phases:'||substr(SQLERRM,1,200);
IF p_update_type in ('ALL', 'PHASE')
THEN
put_line('EXCEPTION RAISED IN PHASE UPDATE'||SQLERRM);
END IF;
When OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	x_return_status_text := 'QP_DENOB.update_pricing_phases:'||substr(SQLERRM,1,200);
IF p_update_type in ('ALL', 'PHASE')
THEN
put_line('EXCEPTION RAISED IN PHASE UPDATE'||SQLERRM);
END IF;
end update_pricing_phases;

procedure update_row_count(p_List_Header_Id_low NUMBER
					 ,p_List_Header_Id_High NUMBER
					 ,p_update_type VARCHAR
					 ,x_return_status OUT NOCOPY VARCHAR2
					 ,x_return_status_text OUT NOCOPY VARCHAR2)
is

/*   Changes for bug 3136350.
This is performance bug fix. The update statement for volume data was taking long time.
Modified the logic to eliminate the corelated query update logic. Changed the login to do
a bulk update.
*/

-- bug 3136350 start

CURSOR upd_distinct_row_count IS
SELECT qpq1.qualifier_context,
       qpq1.qualifier_attribute,
       qpq1.comparison_operator_code,
       qpq1.qualifier_attr_value,
       qpq1.qualifier_attr_value_to,
       count(*) distinct_rows
FROM   qp_qualifiers qpq1
WHERE  qpq1.list_header_id between p_List_Header_Id_low and p_List_Header_Id_High  --5860276
and qpq1.list_header_id is not null
AND    qpq1.active_flag = 'Y'
--for bug 5121471
and qpq1.list_type_code not in ('PRL', 'AGR')
GROUP BY qpq1.qualifier_context,
         qpq1.qualifier_attribute,
         qpq1.comparison_operator_code,
         qpq1.qualifier_attr_value,
         qpq1.qualifier_attr_value_to;

-- bug 3136350 end
begin

--enclosed all fnd_file within this IF block to prevent writing into log
--file as it raises an exception in case of delayed requests bug 1621199
--and batch calls for the same reason as above
        IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
                fnd_file.put_line(FND_FILE.LOG,'Begin Row Count Update');
        END IF;


/* Commented for bug 3136350
        update qp_qualifiers qpq set DISTINCT_ROW_COUNT=
                (select count(*) from qp_qualifiers qpq1 where
                        qpq.qualifier_context=qpq1.qualifier_context and
                        qpq.qualifier_attribute=qpq1.qualifier_attribute and
                        qpq.qualifier_attr_value=qpq1.qualifier_attr_value and
                        nvl(qpq.qualifier_attr_value_to,'-x') = nvl(qpq1.qualifier_attr_value_to,'-x') and
                        qpq.comparison_operator_code=qpq1.comparison_operator_code and
                        qpq1.active_flag='Y' and
                        qpq1.list_header_id is not null
                        and qpq1.list_header_id between p_List_Header_Id_low and p_list_header_id_high)
                where (qpq.list_header_id between p_List_Header_Id_low and p_list_header_id_high);
--                      p_List_Header_Id is null);

*/

-- bug 3136350 start

        FOR rec IN upd_distinct_row_count LOOP

                UPDATE qp_qualifiers qpq
                SET DISTINCT_ROW_COUNT = rec.distinct_rows
                WHERE qpq.qualifier_context = rec.qualifier_context
                AND   qpq.qualifier_attribute = rec.qualifier_attribute
                AND   qpq.comparison_operator_code = rec.comparison_operator_code
                AND   qpq.qualifier_attr_value = rec.qualifier_attr_value
                AND   nvl(qpq.qualifier_attr_value_to,'-x') = nvl(rec.qualifier_attr_value_to,'-x')
                --for bug 5121471
                AND qpq.list_type_code not in ('PRL', 'AGR')
                AND  (qpq.list_header_id between p_List_Header_Id_low and p_list_header_id_high);

        END LOOP;

-- bug 3136350 end

        IF P_UPDATE_TYPE IN ('BATCH','ALL', 'DENORMALIZED') THEN
        commit;
        END IF;

        IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
                fnd_file.put_line(FND_FILE.LOG,'Completed Row Count Update');
        END IF;
        EXCEPTION
	WHEN OTHERS THEN
		x_return_status:= FND_API.G_RET_STS_ERROR;
		x_return_status_text:='Exception In Update Row '||substr(sqlerrm,1,300);
end update_row_count;

PROCEDURE Update_Qualifiers
		  (err_buff out NOCOPY VARCHAR2,
		   retcode out NOCOPY NUMBER,
		   p_List_Header_Id NUMBER,
		   p_List_Header_Id_high NUMBER,
		   p_update_type VARCHAR2,
		   p_dummy VARCHAR2,
		   p_request_id NUMBER := NULL --bug 8359554
		   ) Is

l_old_Header_id 	number := -9999;
l_old_Line_id 		number := -9999;
l_old_qualifier_grouping_no number := -9999;
l_header_qual_exists	Varchar2(1);
l_group_cnt		number := 0;
l_Qual_cnt		number := 0;
L_Search_Ind		Number;
l_Grp_Change		Boolean := FALSE;
l_Grp_Start_Index	number := 1;
l_null_grp_count	number := 0;
l_list_header_id NUMBER :=-1;  -- 7321919
l_list_header_id_low NUMBER :=0;
l_list_header_id_high NUMBER :=0;

TYPE Num_Type IS TABLE OF Number INDEX BY BINARY_INTEGER;
TYPE Char_Type IS TABLE OF Varchar2(1) INDEX BY BINARY_INTEGER;
TYPE Rowid_Type IS TABLE OF rowid INDEX BY BINARY_INTEGER;

l_header_qual_exists_Tbl	Char_Type;
l_group_cnt_Tbl		num_type;
L_Search_Ind_Tbl		num_type;
l_rowid_tbl			Rowid_Type;
l_null_header_id_tbl     num_type;
l_null_line_id_tbl       num_type;
l_null_header_Exists_tbl     num_type;
l_null_line_Exists_tbl       num_type;
l_others_group_cnt_tbl		num_type;
l_qual_cnt_tbl		num_type;

TYPE Char30_Type IS TABLE OF Varchar2(30) INDEX BY BINARY_INTEGER;

l_list_line_id_tbl       num_type;
l_qualification_ind_tbl  num_type;
l_list_type_code_tbl     char30_type;
l_list_header_id_tbl     num_type;

l_return_status        varchar2(1);
l_count                number;
l_qcount                number := 0;   --7321919
l_rows                 NATURAL := 5000;
l_total_rows           number := 0;
l_header_line_change_index	number := 1;
l_list_type_code      varchar2(30);	--5922279
l_max_qual_no         number := 0;  --7038849


/*
   Changed cursor definition for bug 8359554. Added one input parameter l_request_id
   and a where condition to match the passed request id. If the l_request_id is not
   null then cursor will return only those list lines which have been updated
   or inserted for this request.
*/

cursor list_lines_cur(a_list_header_id number,b_list_header_id NUMBER, l_request_id NUMBER)
is
  select /*+ index(l qp_list_lines_n15) index(h qp_list_headers_b_n7)*/     --8418006
         l.list_line_id, l.qualification_ind, h.list_type_code, h.list_header_id
  from   qp_list_lines l, qp_list_headers_b h
  where  l.list_header_id = h.list_header_id
  and    h.active_flag = 'Y'
  and    (h.list_header_id between a_list_header_id and b_list_header_id)
  and decode (l_request_id,null,1,l.REQUEST_ID) = nvl (l_request_id,1) --bug 8359554
  order by h.list_header_id; --7321919
--  or      a_list_header_id is null);

cursor list_headers_cur(a_list_header_id NUMBER, b_list_header_id NUMBER)
is
  select list_header_id
  from   qp_list_headers_b
  where  list_header_id between a_list_header_id and b_list_header_id
  and    list_type_code not in ('PRL', 'AGR', 'PML');

Phase_Exception Exception;

--hw 07/19/02
-- added to assign search_ind = 1 to 'NOT =' only if there's no any other operator
-- in the group
l_search_ind_1_set		number := -1;

--nhase/hw 07/29/02
cursor l_qp_list_header_phases_qual is
select list_header_id, pricing_phase_id from qp_list_header_phases
where list_header_id between
--for bug 5121471
      p_List_Header_Id and p_List_Header_Id_high;
cursor l_line_qual_exc (p_pricing_phase_id number,
			p_list_header_id number) is
select list_line_id from qp_list_lines where
list_header_id = p_list_header_id
and pricing_phase_id = p_pricing_phase_id
minus
select list_line_id from qp_qualifiers where
list_header_id = p_list_header_id
and list_line_id <> -1;
l_list_line_id number;

begin

--*************************************************************************
--To update qp_adv_mod_products for changed lines
--*************************************************************************

IF P_UPDATE_TYPE in ('HVOP_PRICING_SETUP','ALL')
and QP_CODE_CONTROL.Get_Code_Release_Level > '110509' THEN
  Set_HVOP_Pricing(l_return_status, err_buff);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF P_UPDATE_TYPE in ('HVOP_PRICING_SETUP','ALL') THEN
	put_line('Exception in Update_HVOP Profile: '||l_return_status);
    END IF;
    Raise Phase_Exception;
  END IF;
END IF;--P_UPDATE_TYPE = 'HVOP_PRICING_SETUP'

--*************************************************************************
--To update qp_adv_mod_products for changed lines
--*************************************************************************

IF P_UPDATE_TYPE in ('BATCH_ADV_MOD_PRODUCTS', 'ADV_MOD_PRODUCTS','ALL')
and QP_CODE_CONTROL.Get_Code_Release_Level > '110508' THEN
  --for bug 5237249
  IF p_list_header_id IS NOT NULL THEN
     G_LIST_HEADER_ID := p_list_header_id;
  END IF;--5237249

  IF p_list_header_id_high IS NOT NULL THEN
     G_LIST_HEADER_ID_HIGH := p_list_header_id_high;
  END IF;--5237249

  G_UPDATE_TYPE := P_UPDATE_TYPE;

  Update_adv_mod_products(l_return_status, err_buff);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF P_UPDATE_TYPE in ('ADV_MOD_PRODUCTS','ALL') THEN
	put_line('Exception in Update_adv_mod_products: '||l_return_status);
    END IF;
    Raise Phase_Exception;
  END IF;
  retcode := 1;
END IF;--P_UPDATE_TYPE = 'ADV_MOD_PRODUCTS'

--*************************************************************************

--LOOP TO UPDATE PRICING PHASES added by spgopal

--*************************************************************************


IF P_UPDATE_TYPE in ('PHASE','ALL') THEN

	put_line('Begin Update Pricing Phases -  update_type '||p_update_type);

	update_pricing_phases(p_update_type => p_update_type,
				x_return_status => l_return_status,
				x_return_status_text => err_buff);

	IF l_return_status = FND_API.G_RET_STS_ERROR
	THEN
		Raise Phase_Exception;
	END IF;
	commit;
		put_line('Completed Update of Pricing Phases');
END IF;--P_UPDATE_TYPE = 'PHASE'

--************************************************************************

   /***********************************************************************
   Begin code to denormalize qp_pricing_attributes and qp_factor_list_attrs
   for Factor Lists only. -rchellam (08/28/01). POSCO change.
   ***********************************************************************/

   IF p_update_type IN ('ALL','FACTOR','BATCH')
   THEN

     IF P_UPDATE_TYPE IN ('ALL','FACTOR') THEN
       put_line('Begin Factor Attrs Denormalization');
     END IF;

     BEGIN
     QP_Denormalized_Pricing_Attrs.Update_Pricing_Attributes(
                                     p_list_header_id,
                                     p_list_header_id_high,
                                     p_update_type);
     EXCEPTION
	WHEN OTHERS THEN
		put_line('Exception occured while excecuting QP_Denormalized_Pricing_Attrs.Update_Pricing_Attributes');
     END;

     IF P_UPDATE_TYPE IN ('ALL','FACTOR') THEN
       put_line('End Factor Attrs Denormalization');
       put_line('Begin Insertion of Factor List Attrs');
     END IF;

     BEGIN
     QP_Denormalized_Pricing_Attrs.Populate_Factor_List_Attrs(
                                     p_list_header_id,
                                     p_list_header_id_high);
     EXCEPTION
	WHEN OTHERS THEN
		put_line('Exception occured while excecuting QP_Denormalized_Pricing_Attrs.Populate_Factor_List_Attrs');
     END;

     IF P_UPDATE_TYPE IN ('ALL','FACTOR') THEN
       put_line('End Insertion of Factor List Attrs');
     END IF;

   END IF; --If p_update_type in ALL, FACTOR, BATCH
   /***********************************************************************
   End code to denormalize qp_pricing_attributes and qp_factor_list_attrs
   for Factor Lists only. -rchellam (08/28/01). POSCO change.
   ***********************************************************************/

IF p_list_header_id IS NOT NULL
and P_UPDATE_TYPE <> 'BATCH_ADV_MOD_PRODUCTS' THEN

		IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
			put_line('Begin Update list_header_id '||p_list_header_id||' '||p_list_header_id_high||' update_type '||p_update_type);
		END IF;

		if p_list_header_id_high is not null then
		--ensure that p_list_header_id < p_list_header_id_high
			l_list_header_id_low := least(p_list_header_id, p_list_header_id_high);
			l_list_header_id_high := greatest(p_list_header_id, p_list_header_id_high);
		else
			l_list_header_id_low := p_list_header_id;
			l_list_header_id_high := p_list_header_id;
		end if;

		IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
			put_line('list_header_ids '||l_list_header_id_low||'- '||l_list_header_id_high||' update_type '||p_update_type);
		END IF;

		IF p_update_type IN ('QUAL_IND','ALL') THEN --(Qual Ind)

--	IF P_UPDATE_TYPE IN ('ALL','QUAL_IND') THEN
			put_line('Begin Update Qualification_Ind ');
--	END IF;

  			OPEN list_lines_cur(l_list_header_id_low, l_list_header_id_high, p_request_id); --bug 8359554

  	LOOP
    	l_list_line_id_tbl.delete;
    	l_list_header_id_tbl.delete;
    	l_qualification_ind_tbl.delete;
    	l_list_type_code_tbl.delete;

    	FETCH list_lines_cur BULK COLLECT INTO l_list_line_id_tbl,
		l_qualification_ind_tbl, l_list_type_code_tbl,
		l_list_header_id_tbl LIMIT l_rows;

    	EXIT WHEN l_list_line_id_tbl.COUNT = 0;

    	BEGIN

       FOR i IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
	  LOOP
       BEGIN
          --Initialize qualification_ind to 0.
          l_qualification_ind_tbl(i) := 0;

          --If line has rltd modifiers, then increment qual_ind by 1.
          BEGIN
            select 1
	    into   l_count
            from dual where exists
                      (select 'x'
	               from   qp_rltd_modifiers
		       where  to_rltd_modifier_id = l_list_line_id_tbl(i)
	       	       and    rltd_modifier_grp_type <> 'COUPON');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_count := 0;
          END;

   	  IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 1;
	  END IF;

          --If line belongs to Price List or Agreement and if the PRL or AGR
		--has header-level qualifier other than Primary PL that are
		--qualifiers of Secondary PLs, then increment qual_ind by 2.
          IF l_list_type_code_tbl(i) IN ('AGR', 'PRL') THEN
          	--added for 5922279
                IF l_list_header_id_low = l_list_header_id_high then
	               l_list_type_code:= l_list_type_code_tbl(l_list_type_code_tbl.FIRST);
                End if;
        	--Bug#7321919: No need to run the same query if the header id is the same.
	    IF l_list_header_id_tbl(i) <> l_list_header_id THEN
            BEGIN
              select 1
	      into   l_count
              from dual where exists
                        (select 'x'
		         from   qp_qualifiers
		         where  list_header_id = l_list_header_id_tbl(i)
		         and    NOT (qualifier_context = 'MODLIST' and
				  qualifier_attribute = 'QUALIFIER_ATTRIBUTE4')
                        );
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;
	    l_list_header_id := l_list_header_id_tbl(i);
	     l_qcount := l_count;
            ELSE
	       l_count := l_qcount;
	    END IF;                  --7321919

	    IF l_count > 0 THEN
              l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
	    END IF;

	  --For all other list header types
          ELSE
	    --If header-level qualifier exists for the list_header_id then
	    --increment qual ind by 2
            BEGIN
              select 1
	      into   l_count
              from dual where exists
                        (select 'x'
		         from   qp_qualifiers
		         where  list_header_id = l_list_header_id_tbl(i)
		         and    nvl(list_line_id,-1) = -1);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;

	    IF l_count > 0 THEN
              l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
	    END IF;

	    --If line-level qualifier exists for the list_line_id then
	    --increment qual ind by 8
            BEGIN
              select 1
	      into   l_count
              from dual where exists
                        (select 'x'
		         from   qp_qualifiers
		         where  list_header_id = l_list_header_id_tbl(i)
		         and    list_line_id = l_list_line_id_tbl(i));
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_count := 0;
            END;

	    IF l_count > 0 THEN
              l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 8;
	    END IF;

          END IF;

          --If line has product attributes, then increment qual_ind by 4.
          BEGIN
	    select 1
	    into   l_count
            from dual where exists
                      (select 'x'
		       from   qp_pricing_attributes
		       where  list_line_id = l_list_line_id_tbl(i)
		       and    excluder_flag = 'N');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_count := 0;
          END;

	  IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 4;
	  END IF;

          --If line has pricing attributes, then increment qual_ind by 16.
          BEGIN
	    select 1
	    into   l_count
            from dual where exists
                      (select 'x'
		       from   qp_pricing_attributes
		       where  list_line_id = l_list_line_id_tbl(i)
		       and    pricing_attribute_context is not null
		       and    pricing_attribute is not null
		       -- changes made per rchellam's request--spgopal
		       and pricing_attr_value_from IS NOT NULL);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_count := 0;
          END;

	  IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 16;
	  END IF;

       EXCEPTION
		WHEN OTHERS THEN
			IF P_UPDATE_TYPE IN ('ALL','QUAL_IND') THEN
            		put_line( substr(sqlerrm, 1, 240) );
            		put_line(
	        			'Error in processing list_line_id '||
		    			to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)));
	   		END IF;

       END;
	  END LOOP; --End of For Loop

       FORALL j IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
          UPDATE qp_list_lines
		SET    qualification_ind = l_qualification_ind_tbl(j)
		WHERE  list_line_id = l_list_line_id_tbl(j);

       FORALL k IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
          UPDATE qp_pricing_attributes
		SET    qualification_ind = l_qualification_ind_tbl(k)
		WHERE  list_line_id = l_list_line_id_tbl(k);

       l_total_rows := l_total_rows + SQL%ROWCOUNT;

    EXCEPTION
	 WHEN OTHERS THEN
		IF P_UPDATE_TYPE IN ('ALL','QUAL_IND') THEN
        		put_line( substr(sqlerrm, 1, 240));
        		put_line(
	     		'Error in processing list_line_id '||
		  		to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)));
		END IF;

    END;

    COMMIT; --after every 5000(l_rows) lines are processed

  END LOOP; --End of cursor loop

  CLOSE list_lines_cur;

	IF P_UPDATE_TYPE IN ('ALL','QUAL_IND') THEN
  		put_line('Qualification_Ind Update Completed');
  		put_line( to_char(l_total_rows) || ' list lines processed');
	END IF;

     END IF; --IF update_type IN (ALL, QUAL_IND), (see matching (Qual Ind))

    /************************************************************************
     Begin code to maintain qp_list_header_phases for modifierlist types only
     ************************************************************************/
     IF P_UPDATE_TYPE IN ('BATCH','HEADER_PHASE','ALL')
     THEN

       IF P_UPDATE_TYPE IN ('ALL','HEADER_PHASE') THEN
         put_line('Begin Maintain List Header Phases ');
       END IF;

       --ensure that p_list_header_id < p_list_header_id_high
       IF p_list_header_id_high IS NOT NULL THEN
	 l_list_header_id_low := least(p_list_header_id, p_list_header_id_high);
	 l_list_header_id_high :=
		greatest(p_list_header_id, p_list_header_id_high);
       ELSE
	 l_list_header_id_low := p_list_header_id;
	 l_list_header_id_high := p_list_header_id;
       END IF;

       FOR l_rec in list_headers_cur(l_list_header_id_low,l_list_header_id_high)
       LOOP
         delete from qp_list_header_phases
         where list_header_id = l_rec.list_header_id;

      /*
          Bug - 8224336
          Changes for Pattern Engine - added column PRIC_PROD_ATTR_ONLY_FLAG
          Column PRIC_PROD_ATTR_ONLY_FLAG in table qp_list_header_phases will be -
	  'Y' - If all the lines in the header for that phase have only product or pricing or both attributes (but not qualifiers).
	  'N' - If atleast one line within that header or header itself has qualifiers attached, for that phase
       */

         insert into qp_list_header_phases (list_header_id,pricing_phase_id,PRIC_PROD_ATTR_ONLY_FLAG)  /* Added column names for 2236671 */
         (select distinct list_header_id, pricing_phase_id,'N'
	  from   qp_list_lines
	  where  pricing_phase_id > 1
	  and    qualification_ind in (2,6,8,10,12,14,22,28,30)
	  and    list_header_id = l_rec.list_header_id);

       END LOOP;

       commit;

       IF P_UPDATE_TYPE IN ('ALL','HEADER_PHASE') THEN
        put_line('Completed Maintain List Header Phases');
       END IF;

     /************************************************************************
      End code to maintain qp_list_header_phases -rchellam.  Moved this code
      to below the qualification_ind code (05/29/01) -rchellam
      ************************************************************************/

ELSE
	--We do not want the update of qualification_ind when calling from delayed request package as this would have been done already by the other delayed requests update_list_qual_ind and update_line_qual_ind --spgopal
	null;
END IF; --p_list_header_is is not null


IF p_update_type IN ('BATCH', 'ALL', 'DENORMALIZED', 'DELAYED_REQ', 'UPD_QUAL') THEN
--we want to process the request for different updates based on update type

--Added for 5922279. procedure update_row_count does not need to be called for AGR,PRL through UI
IF NOT( l_list_header_id_low = l_list_header_id_high AND l_list_type_code in ('PRL','AGR')) then
Update_row_count(l_list_header_id_low,l_list_header_id_high, p_update_type,l_return_status,err_buff);
IF l_return_status=FND_API.G_RET_STS_ERROR THEN
        	put_line('Exception While Updating Row Count'||l_return_status);
         Raise Phase_Exception;
      END IF;
END IF;
	IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
		put_line('Begin Update Denormalized columns ');
	END IF;

/* Added for bug 7038849 */
BEGIN
	SELECT MAX(ABS(qualifier_grouping_no))
	INTO l_max_qual_no
	FROM qp_qualifiers
	WHERE list_header_id  between l_list_header_id_low and l_list_header_id_high;
EXCEPTION
WHEN OTHERS THEN
l_max_qual_no:= 0;
END;
/* Added for bug7038849--changed order by clause
   logic has been changed to support -ve qualifier grouping no. other than -1.
   When max absolute value is added to qualifier grp no, result will be always positive or zero
   for non -1 qualifier grp no and hence during order by, -1 qualifier grp no will come at the top
   in result due to decode. This way we dont have to change any pl/sql logic
*/



--hw
-- this is for modifier only
for c1 in (select rowid,list_header_id,nvl(list_line_id,-1) list_line_id,
nvl(qualifier_grouping_no,-1) qualifier_grouping_no, Distinct_row_count, comparison_operator_code
from qp_qualifiers
where (list_header_id between l_list_header_id_low and l_list_header_id_high)
and list_type_code not in ('PRL','AGR')
--order by list_header_id,nvl(list_line_id,-1),decode(nvl(qualifier_grouping_no,-1), -1, -9999, qualifier_grouping_no), comparison_operator_code, Distinct_row_count) -- 7038849
order by list_header_id,nvl(list_line_id,-1),decode(nvl(qualifier_grouping_no,-1),-1,nvl(qualifier_grouping_no,-1),nvl(qualifier_grouping_no,-1)+l_max_qual_no), comparison_operator_code, Distinct_row_count) -- 7038849
loop

	--oe_debug_pub.add(c1.rowid ||', '|| c1.list_header_id ||', '|| c1.list_line_id ||', '|| c1.qualifier_grouping_no ||', '|| l_qual_cnt ||', '|| l_group_cnt ||', '|| l_null_grp_count);

	if l_old_header_id <> c1.list_header_id
	then
		l_grp_Change := TRUE;
		l_header_qual_exists := 'N';
	end if; -- Grp no has changed.

	If c1.list_line_id = -1 then
		l_header_qual_exists := 'Y';
	End If;

	if l_old_line_id <> c1.list_line_id
	then
		l_grp_Change := TRUE;
	end if; -- Grp no has changed.


	if l_old_qualifier_grouping_no <> c1.qualifier_grouping_no
	then
	  l_grp_Change := TRUE;
	end if; -- Grp no has changed.

	If l_grp_Change then
		l_grp_Change := FALSE;

		--hw
		--if 'not =' is the only operator in this group (when l_search_ind_1_set is not set),
		--then reset the search_ind to 1
		if l_search_ind_1_set = 0 then
			l_search_ind_tbl(l_search_ind_tbl.count) := 1;
		end if;
		l_search_ind_1_set := 0;

		/* Update the rows of the group with group count */
		If l_group_cnt_tbl.count > 0 then

			For k in l_Grp_Start_Index..l_group_cnt_tbl.Last loop
		    		If c1.qualifier_grouping_no <> -1 then
                     If (c1.list_header_id = l_old_header_id and
				      c1.list_line_id = l_old_line_id and l_null_grp_count > 0 ) then
			--fix for bug 2102211 performance problem
			--populating the l_null_header_id_tbl and
			--l_null_line_id_tbl only when list_header_id
			--or list_line_id changes
		      If not l_null_header_exists_tbl.exists(l_old_header_id) then
			l_null_header_exists_tbl(l_old_header_id) := 1;
			l_null_Line_exists_tbl.delete;
		      end if;
		      If not l_null_Line_exists_tbl.exists(l_old_Line_id) then
			l_null_Line_exists_tbl(l_old_line_id ) := 1;
			l_null_header_id_tbl(l_null_header_id_tbl.count+1) := l_old_header_id;
			l_null_line_id_tbl(l_null_line_id_tbl.count+1) := l_old_line_id;
		      end if;
                     End If;--l_null_grp_cnt > 0
                    End If;--c1.qualifier_grouping_no <> -1

				If l_old_qualifier_grouping_no <> -1 then
				  l_group_cnt_tbl(k) := l_group_cnt + l_null_grp_count;
				else
				  l_group_cnt_tbl(k) := l_group_cnt;
				End If;

			End Loop;

		  --hw
		if l_old_header_id <> c1.list_header_id or l_old_line_id <> c1.list_line_id then

			--oe_debug_pub.add('l_header_line_change_index, l_group_cnt_tbl.last: ' || l_header_line_change_index ||', '|| l_group_cnt_tbl.last);

			for k in l_header_line_change_index..l_group_cnt_tbl.last loop
				l_others_group_cnt_tbl(k) := l_qual_cnt - l_null_grp_count;
			end loop;

		If l_header_qual_exists_tbl.count >= 1000 then
			Forall K in l_header_qual_exists_tbl.First..l_header_qual_exists_tbl.Last
			update qp_qualifiers
			Set 	SEARCH_IND = L_Search_Ind_tbl(K),
				QUALIFIER_GROUP_CNT = l_group_cnt_tbl(K),
--				qualifier_group_cnt = decode(qualifier_grouping_no, -1, 0, l_group_cnt_tbl(k)),
				HEADER_QUALS_EXIST_FLAG=l_header_qual_exists_tbl(K),
				others_group_cnt = l_others_group_cnt_tbl(k)
			Where rowid = l_rowid_tbl(K)
			and list_type_code not in ('PRL', 'AGR');

			IF p_update_type IN ('BATCH','DENORMALIZED', 'ALL') THEN
				Commit;
			END IF;

			l_rowid_tbl.delete;
			L_Search_Ind_tbl.delete;
			l_group_cnt_tbl.delete;
			l_others_group_cnt_tbl.delete;
			l_header_qual_exists_tbl.delete;
		End If; -- > 1000
			l_qual_cnt := 0;
	      	l_null_grp_count := 0;
			l_header_line_change_index := l_search_ind_tbl.count + 1;

		end if; -- header or line changed

		end If; -- l_group_cnt_tbl.count > 0


		l_group_cnt := 0;
		l_Grp_Start_Index := L_Search_Ind_tbl.count+1;

	end If; --  The Line or header has changed or group_no changed

	l_group_cnt := l_group_cnt +1;
	l_qual_cnt := l_qual_cnt + 1;

     If  c1.qualifier_grouping_no = -1 then
	   l_null_grp_count := l_null_grp_count+1;
	end If;

	if l_group_cnt = 1 then
		if c1.comparison_operator_code <> 'NOT =' then
			l_search_ind := 1;
			l_search_ind_1_set := 1;
		else
			l_search_ind := 2;
		end if;
	else
		if l_search_ind_1_set <> 1 and c1.comparison_operator_code <> 'NOT =' then
			l_search_ind := 1;
			l_search_ind_1_set := 1;
		else
			l_search_ind := 2;
		end if;
	end if;

	l_rowid_tbl(l_rowid_tbl.count+1) := c1.rowid;
	L_Search_Ind_tbl(L_Search_Ind_tbl.count+1) := L_Search_Ind;
	l_group_cnt_tbl(l_group_cnt_tbl.count+1) := l_group_cnt;
	l_header_qual_exists_tbl(l_header_qual_exists_tbl.count+1) := l_header_qual_exists;

	l_old_header_id := c1.list_header_id;
	l_old_line_id   := c1.list_line_id;
	l_old_qualifier_grouping_no :=  c1.qualifier_grouping_no;

end loop;

		 --update the remaining groups
		if l_search_ind_1_set = 0 then
			l_search_ind_tbl(l_search_ind_tbl.count) := 1;
		end if;
		l_search_ind_1_set := 0;

	    IF (l_group_cnt_tbl.COUNT > 0 ) THEN
		For k in l_Grp_Start_Index..l_group_cnt_tbl.Last loop

			If l_old_qualifier_grouping_no <> -1 then
				l_group_cnt_tbl(k) := l_group_cnt + l_null_grp_count;
			Else
				l_group_cnt_tbl(k) := l_group_cnt ;
			End If;

		End Loop;

			--oe_debug_pub.add('l_header_line_change_index, l_group_cnt_tbl.last: ' || l_header_line_change_index ||', '|| l_group_cnt_tbl.last);

			for k in l_header_line_change_index..l_group_cnt_tbl.last loop
				l_others_group_cnt_tbl(k) := l_qual_cnt - l_null_grp_count;
			end loop;

		If l_header_qual_exists_tbl.count > 0 then
			Forall K in l_header_qual_exists_tbl.First..l_header_qual_exists_tbl.Last
			update qp_qualifiers
			Set 	SEARCH_IND = L_Search_Ind_tbl(K),
				QUALIFIER_GROUP_CNT = l_group_cnt_tbl(K),
--				qualifier_group_cnt = decode(qualifier_grouping_no, -1, 0, l_group_cnt_tbl(k)),
				HEADER_QUALS_EXIST_FLAG=l_header_qual_exists_tbl(K),
				others_group_cnt = l_others_group_cnt_tbl(k)
			Where rowid = l_rowid_tbl(K)
			and list_type_code not in ('PRL', 'AGR');

			IF P_UPDATE_TYPE IN ('BATCH','DENORMALIZED', 'ALL', 'UPD_QUAL') THEN
				Commit;
			END IF;

			/*
			For K in l_header_qual_exists_tbl.First..l_header_qual_exists_tbl.Last loop
				oe_debug_pub.add('	update: ' || l_rowid_tbl(K) ||', '|| l_group_cnt_tbl(K) ||', '|| l_others_group_cnt_tbl(K));
			end loop;
			*/

			l_rowid_tbl.delete;
			L_Search_Ind_tbl.delete;
			l_group_cnt_tbl.delete;
			l_others_group_cnt_tbl.delete;
			l_header_qual_exists_tbl.delete;
		End If;

         END IF;

		-- Update all the null grouping number rows to search ind 2 , if there is any other grp
		If l_null_header_id_tbl.count > 0 then
		 Forall J in l_null_header_id_tbl.First..l_null_header_id_tbl.Last
		 update qp_qualifiers
		 set search_ind = 2
--			qualifier_group_cnt = qualifier_group_cnt + 1 -- Arbitary increasing the ct by 1 for null grp -- dont care
		 where nvl(qualifier_grouping_no,-1) = -1
		 and   list_header_id = l_null_header_id_tbl(J)
		 and   list_line_id = l_null_line_id_tbl(J);

		 	IF P_UPDATE_TYPE IN ('BATCH' ,'DENORMALIZED', 'ALL')THEN
		 		commit;
		 	END IF;
		End If;

END IF;--p_update_type in 'BATCH', 'DENORMALIZED', 'ALL', 'DELAYED_REQ'
    -- set return status
    err_buff := '';
    retcode  := 0;

		IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND') THEN
			put_line('Completed Update Denormalized columns ');
		END IF;

ELSE
	IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND','HEADER PHASE') THEN
		put_line('Could not perform updates');
		put_line('At least one value of modifier list or pricelist must be entered');
		err_buff :='Could not perform updates , At least one value of modifier list or pricelist must be entered';
                retcode:=2;
	END IF;
END IF;

-- This procedure update the qualifier flag to Y if all the lines of the header have line level qualifiers.
-- set the flag to null for all records
	IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND','HEADER PHASE','UPD_QUAL', 'BATCH') THEN --BATCH added for bug 5121471
update qp_list_header_phases set qualifier_flag = null;
for i in l_qp_list_header_phases_qual
loop
l_list_line_id := Null;
open l_line_qual_exc(i.pricing_phase_id, i.list_header_id);
fetch l_line_qual_exc into  l_list_line_id;
close l_line_qual_exc;
if l_list_line_id is null then
	update qp_list_header_phases
	set qualifier_flag = 'Y'
	where list_header_id = i.list_header_id
	and pricing_phase_id = i.pricing_phase_id;
end if;
l_list_line_id := null;
end loop;
end if;


    EXCEPTION
     When Phase_Exception Then
	retcode := -1;
     WHEN OTHERS THEN
		IF P_UPDATE_TYPE IN ('ALL','DENORMALIZED','QUAL_IND','HEADER_PHASE', 'FACTOR') THEN
	  		put_line(substr(sqlerrm,1,300));
		END IF;
		err_buff := substr(sqlcode,1,50)||' : '||substr(sqlerrm,1,250);
       		retcode := 2;

END Update_Qualifiers;

End QP_Maintain_Denormalized_Data;

/
