--------------------------------------------------------
--  DDL for Package Body PER_ZA_WSP_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_WSP_XML_GEN_PKG" as
/* $Header: perzawspg.pkb 120.1.12010000.3 2009/08/17 06:06:26 rbabla ship $ */
 /*
 +======================================================================+
 | Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA|
 |                       All rights reserved.                           |
 +======================================================================+
 Package Name         : PER_ZA_WSP_XML_GEN_PKG
 Package File Name    : perzawspg.pkb
 Description          : This sql script seeds the Package Body that
                        generates XML data for WSP report.

    Change List       : perzaxmlg.pkb
    ------------
    Name          Date          Version  Bug     Text
    ------------- ------------- ------- ------- ------------------------------
    Kaladhaur     27-DEC-2006   115.0           First created
    R V Pahune    05-Feb-2007   115.0           Changed the action context type
                                                to AAP for person details.
    A. Mahanty    19-Feb-2007   115.0           Changed the race codes
    A. Mahanty    20-Feb-2007   115.1           A3 part of the report shows
    																						one entry per person and not
    																						by learning intervention.
    A. Mahanty    25-Feb-2007		115.2           Added Totals calculation for WSP
    																						and ATR (A3 and B3). Added date
    																						fields to the report
	  A. Mahanty    06-Mar-2007   115.3						p_xml was opened explicitly	in
	  																						populate_xml_data
    R Babla       11-Aug-2009   115.5  8468137   Updated procedure update_company_data to select and pass the
                                                 value of SDL Number
    R Babla       17-Aug-2009   115.6  8468137	 Updated procedure update_company_data to correctly pass the value
                                                 of SDL Number
    ========================================================================*/
--
-- Global Variables
--
g_package                constant varchar2(31) := 'PER_ZA_WSP_XML_GEN_PKG.';
g_debug                  boolean;
--
type xml_dom_table is table of xmldom.DOMNode index by binary_integer;
--
g_xml_dom                xmldom.DOMDocument;
g_node_list              xml_dom_table;
--
g_root_level             constant binary_integer := 0;
g_company_level          constant binary_integer := 1;
g_company_name_level     constant binary_integer := 2;
g_company_name_lin_level constant binary_integer := 3;
g_company_add_level      constant binary_integer := 2; -- for both physical and postal
g_company_add_det_level  constant binary_integer := 3; -- for both physical and postal
g_company_sdf_level      constant binary_integer := 2;
g_company_sdf_add_level  constant binary_integer := 3;
g_company_bank_level     constant binary_integer := 2;
g_company_bank_add_level constant binary_integer := 3;
g_company_det_level      constant binary_integer := 2;

g_wsp_level              constant binary_integer := 1;
g_wsp_date_level         constant binary_integer := 2;
g_wsp_trng_level         constant binary_integer := 2;
g_wsp_trng_det_level     constant binary_integer := 3;
g_wsp_benf_level         constant binary_integer := 2;
g_wsp_benf_det_level     constant binary_integer := 3;

g_atr_level              constant binary_integer := 1;
g_atr_trng_level         constant binary_integer := 2;
g_atr_trng_det_level     constant binary_integer := 3;
g_atr_benf_level         constant binary_integer := 2;
g_atr_benf_det_level     constant binary_integer := 3;

--
/*--------------------------------------------------------------------------
  Name      : preprocess_value
  Purpose   : Called from PY_ZA_SRS_WSP_PREID valueset
  Arguments :
--------------------------------------------------------------------------*/
function preprocess_value
   (
   p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
   p_legislative_parameters in pay_payroll_actions.legislative_parameters%type
   )
return varchar2 is

l_preprocess_value      varchar2(80);

begin

   l_preprocess_value := 'Plan Year=';
   l_preprocess_value := l_preprocess_value || pay_za_uif_archive_pkg.get_parameter('PLAN_YEAR', p_legislative_parameters);
   l_preprocess_value := l_preprocess_value ||'('||to_char(p_payroll_action_id)||')';

   return l_preprocess_value;

end preprocess_value;

--
/*--------------------------------------------------------------------------
  Name      : update_dom
  Purpose   : Update a node to XML DOM.
  Arguments :
--------------------------------------------------------------------------*/
procedure update_dom( p_name   varchar2
                    , p_text   varchar2
                    , p_level  binary_integer) is

parent_node  xmldom.DOMNode;

item_node    xmldom.DOMNode;
item_elmt    xmldom.DOMElement;
item_text    xmldom.DOMText;

begin
    parent_node := g_node_list(p_level);

    item_elmt := xmldom.createElement(g_xml_dom, p_name);
    item_node := xmldom.appendChild(parent_node, xmldom.makeNode(item_elmt));

    if p_text is not null
    then
        item_text := xmldom.createTextNode(g_xml_dom, p_text);
        item_node := xmldom.appendChild(item_node, xmldom.makeNode(item_text));
    end if;

    g_node_list(p_level+1) := item_node;
end update_dom;
--
/*--------------------------------------------------------------------------
  Name      : update_company_data
  Purpose   : Updates employer data to XML DOM.
              Assumes g_xml_dom is already initialized.
  Arguments :
--------------------------------------------------------------------------*/
procedure update_company_data( p_legal_entity_id     in number
                              , p_payroll_action_id     in varchar2) is

l_proc           varchar2(100) := g_package || 'update_company_data';

cursor csr_comp_contacts is
    select action_information3    org_name
         , action_information4    post_add_line_1     -- A(1).2 Postal Address
         , action_information5    post_add_line_2
         , action_information6    post_add_line_3
         , action_information8    post_town_or_city
         , action_information9    post_postal_code
         , action_information10   post_province
         , action_information11   phy_add_line_1      -- A(1).3 Physical Address
         , action_information12   phy_add_line_2
         , action_information13   phy_add_line_3
         , action_information15   phy_town_or_city
         , action_information16   phy_postal_code
         , action_information17   phy_province
         , action_information18   tel_no              -- A(1).5 Telephone number
         , action_information19   fax_no              -- A(1).6 Fax number
         , action_information20   email_add           -- A(1).7 E-mail Address
	 , action_information23   sdl_no
      from pay_action_information
     where action_context_id           = p_payroll_action_id
       and action_information_category = 'ZA WSP EMPLOYER DETAILS'
       and action_information2         = p_legal_entity_id
       and action_context_type         = 'PA';

comp_contacts_rec    csr_comp_contacts%rowtype;

cursor csr_comp_sdf_det is
    select action_information3    sdf_name            -- A(1).12 SDF Name
         , action_information4    sdf_add_line_1      -- A(1).13 SDF Address
         , action_information5    sdf_add_line_2
         , action_information6    sdf_add_line_3
         , action_information7    sdf_town_or_city
         , action_information8    sdf_postal_code
         , action_information9    sdf_province
         , action_information10   sdf_tel             -- A(1).14 SDF contact details
         , action_information11   sdf_mobile
         , action_information12   sdf_fax
         , action_information13   sdf_email
      from pay_action_information
     where action_context_id           = p_payroll_action_id
       and action_information_category = 'ZA WSP SDF DETAILS'
       and action_information2         = p_legal_entity_id
       and action_context_type         = 'PA';

comp_sdf_det_rec    csr_comp_sdf_det%rowtype;

begin
    hr_utility.set_location ('Entering ' || l_proc, 10);

-- Update EMPLOYER DETAILS
    open csr_comp_contacts;
    fetch csr_comp_contacts into comp_contacts_rec;
    close csr_comp_contacts;

    update_dom('COMPANY', null, g_company_level);

    update_dom('NAME', null, g_company_name_level);
    update_dom('LINE_1', comp_contacts_rec.org_name, g_company_name_lin_level);

    update_dom('POSTAL_ADDRESS', null, g_company_add_level);
    update_dom('ADDRESS_LINE_1', comp_contacts_rec.post_add_line_1  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_2', comp_contacts_rec.post_add_line_2  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_3', comp_contacts_rec.post_add_line_3  , g_company_add_det_level);
    update_dom('TOWN_CITY'     , comp_contacts_rec.post_town_or_city, g_company_add_det_level);
    update_dom('POSTAL_CODE'   , comp_contacts_rec.post_postal_code , g_company_add_det_level);
    update_dom('PROVINCE'      , comp_contacts_rec.post_province    , g_company_add_det_level);

    update_dom('PHYSICAL_ADDRESS', null, g_company_add_level);
    update_dom('ADDRESS_LINE_1'  , comp_contacts_rec.phy_add_line_1  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_2'  , comp_contacts_rec.phy_add_line_2  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_3'  , comp_contacts_rec.phy_add_line_3  , g_company_add_det_level);
    update_dom('TOWN_CITY'       , comp_contacts_rec.phy_town_or_city, g_company_add_det_level);
    update_dom('POSTAL_CODE'     , comp_contacts_rec.phy_postal_code , g_company_add_det_level);
    update_dom('PROVINCE'        , comp_contacts_rec.phy_province    , g_company_add_det_level);

    update_dom('TEL'    , comp_contacts_rec.tel_no  , g_company_det_level);
    update_dom('FAX'    , comp_contacts_rec.fax_no  , g_company_det_level);
    update_dom('E-MAIL' ,comp_contacts_rec.email_add, g_company_det_level);
    update_dom('SDL'    ,comp_contacts_rec.sdl_no   , g_company_det_level);


-- Update WSP SDF DETAILS
    open csr_comp_sdf_det;
    fetch csr_comp_sdf_det into comp_sdf_det_rec;
    close csr_comp_sdf_det;

    update_dom('SDF_NAME', comp_sdf_det_rec.sdf_name, g_company_det_level);

    update_dom('SDF_ADDRESS', null, g_company_add_level);
    update_dom('ADDRESS_LINE_1'     , comp_sdf_det_rec.sdf_add_line_1  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_2'     , comp_sdf_det_rec.sdf_add_line_2  , g_company_add_det_level);
    update_dom('ADDRESS_LINE_3'     , comp_sdf_det_rec.sdf_add_line_3  , g_company_add_det_level);
    update_dom('TOWN_CITY'          , comp_sdf_det_rec.sdf_town_or_city, g_company_add_det_level);
    update_dom('POSTAL_CODE'        , comp_sdf_det_rec.sdf_postal_code , g_company_add_det_level);
    update_dom('PROVINCE'           , comp_sdf_det_rec.sdf_province    , g_company_add_det_level);

    update_dom('SDF_TEL'   , comp_sdf_det_rec.sdf_tel   , g_company_det_level);
    update_dom('SDF_MOBILE', comp_sdf_det_rec.sdf_mobile, g_company_det_level);
    update_dom('SDF_FAX'   , comp_sdf_det_rec.sdf_fax   , g_company_det_level);
    update_dom('SDF_EMAIL' , comp_sdf_det_rec.sdf_email , g_company_det_level);
--
    hr_utility.set_location('Leaving ' || l_proc, 10);

end update_company_data;
--
/*--------------------------------------------------------------------------
  Name      : update_wsp_data
  Purpose   : Updates WSP(Training and Beneficiary) data to XML DOM.
              Assumes g_xml_dom is already initialized.
  Arguments :
--------------------------------------------------------------------------*/
procedure update_wsp_data( p_legal_entity_id     in number
                         , p_payroll_action_id     in varchar2) is

l_proc     varchar2(100) := g_package || 'update_wsp_data';

cursor csr_wsp_trng is
    select action_information3    sk_num              -- Skills priority number (i.e serial number)
         , action_information4    training_priority   -- Skills priority ( Education/ Training priority)
         , action_information5    lev_1
         , action_information6    lev_2
         , action_information7    lev_3
         , action_information8    lev_4
         , action_information9    lev_5
         , action_information10   lev_6
         , action_information11   lev_7
         , action_information12   lev_8
         , action_information13   unknown
         , action_information14   saqa_yes
         , action_information15   saqa_no
         , action_information16   saqa_id
         , action_information17   year
      from pay_action_information
     where action_context_id           = p_payroll_action_id
       and action_information_category = 'ZA WSP TRAINING PROGRAMS'
       and action_information2         = p_legal_entity_id
       and action_context_type         = 'PA'
       order by sk_num;

-- changed action_context_type from PA to AAP
cursor csr_wsp_occ is
    select pai.action_information6       occ_cat
      from pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where ppa.payroll_action_id = p_payroll_action_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA WSP PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
     group by pai.action_information6;

cursor csr_wsp_occ_recs( p_occ_cat  varchar) is
    select distinct pai.action_information3 person_id
    		 , pai.action_information4   race
         , pai.action_information5   sex
         , pai.action_information7   disability
      from  pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where  ppa.payroll_action_id = p_payroll_action_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA WSP PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
       and pai.action_information6         = p_occ_cat;

cursor csr_wsp_occ_sk_prs( p_occ_cat  varchar) is
    select distinct pai.action_information11   sk_pr_num
      from  pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where  ppa.payroll_action_id          = p_payroll_action_id
       AND paa.payroll_action_id           = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA WSP PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
       and pai.action_information6         = p_occ_cat
       order by sk_pr_num;


l_ma    number(15);
l_fa    number(15);
l_da    number(15);

l_mc    number(15);
l_fc    number(15);
l_dc    number(15);

l_mi    number(15);
l_fi    number(15);
l_di    number(15);

l_mw    number(15);
l_fw    number(15);
l_dw    number(15);

l_mt    number(15);
l_ft    number(15);
l_dt    number(15);
--For Grand Totals
l_wsp_ma_sum				number(15) := 0;
l_wsp_fa_sum        number(15) := 0;
l_wsp_da_sum        number(15) := 0;

l_wsp_mc_sum        number(15) := 0;
l_wsp_fc_sum        number(15) := 0;
l_wsp_dc_sum        number(15) := 0;

l_wsp_mi_sum        number(15) := 0;
l_wsp_fi_sum        number(15) := 0;
l_wsp_di_sum        number(15) := 0;

l_wsp_mw_sum        number(15) := 0;
l_wsp_fw_sum        number(15) := 0;
l_wsp_dw_sum        number(15) := 0;

l_wsp_mt_sum        number(15) := 0;
l_wsp_ft_sum        number(15) := 0;
l_wsp_dt_sum        number(15) := 0;

l_wsp_end_year  number(4);
l_leg_parameters   varchar2(2000);

l_sk_pr_num varchar2(2000);
/*
01  Indian
02  African
03  Coloured
04  White
*/

begin
	  --hr_utility.trace_on(null,'ZAWSPG');
    hr_utility.set_location ('Entering ' || l_proc, 10);

-- WSP year
 select legislative_parameters
 into l_leg_parameters
 from pay_payroll_actions
 where payroll_action_id = p_payroll_action_id;
--
l_wsp_end_year := to_number(per_za_wsp_archive_pkg.get_parameter('PLAN_YEAR',l_leg_parameters));

hr_utility.set_location ('l_wsp_end_year :'||l_wsp_end_year,10);

if l_wsp_end_year is null then
	l_wsp_end_year := 4712;
end if;

--  Create parent node for WSP data
    update_dom('WSP', null, g_wsp_level);
    hr_utility.set_location ('WSP :',10);
		update_dom('WSP_START_YEAR', l_wsp_end_year - 1, g_wsp_date_level);
		update_dom('WSP_END_YEAR', l_wsp_end_year, g_wsp_date_level);

-- Update WSP Training Details
    for wsp_trng_rec in csr_wsp_trng
    loop
        update_dom('TRAINING_DETAILS', null, g_wsp_trng_level);
        update_dom('SK_NUM'           , wsp_trng_rec.sk_num           , g_wsp_trng_det_level);
        update_dom('TRAINING_PRIORITY', wsp_trng_rec.training_priority, g_wsp_trng_det_level);
        update_dom('LEV_1'            , wsp_trng_rec.lev_1            , g_wsp_trng_det_level);
        update_dom('LEV_2'            , wsp_trng_rec.lev_2            , g_wsp_trng_det_level);
        update_dom('LEV_3'            , wsp_trng_rec.lev_3            , g_wsp_trng_det_level);
        update_dom('LEV_4'            , wsp_trng_rec.lev_4            , g_wsp_trng_det_level);
        update_dom('LEV_5'            , wsp_trng_rec.lev_5            , g_wsp_trng_det_level);
        update_dom('LEV_6'            , wsp_trng_rec.lev_6            , g_wsp_trng_det_level);
        update_dom('LEV_7'            , wsp_trng_rec.lev_7            , g_wsp_trng_det_level);
        update_dom('LEV_8'            , wsp_trng_rec.lev_8            , g_wsp_trng_det_level);
        update_dom('UNKNOWN'          , wsp_trng_rec.unknown          , g_wsp_trng_det_level);
        update_dom('SAQA_YES'         , wsp_trng_rec.saqa_yes         , g_wsp_trng_det_level);
        update_dom('SAQA_NO'          , wsp_trng_rec.saqa_no          , g_wsp_trng_det_level);
        update_dom('SAQA_ID'          , wsp_trng_rec.saqa_id          , g_wsp_trng_det_level);
    end loop;

--  Update WSP Beneficiary details
    for wsp_occ_rec in csr_wsp_occ
    loop
        l_ma := 0; l_fa := 0; l_da := 0;
        l_mc := 0; l_fc := 0; l_dc := 0;
        l_mi := 0; l_fi := 0; l_di := 0;
        l_mw := 0; l_fw := 0; l_dw := 0;
        l_mt := 0; l_ft := 0; l_dt := 0;

        l_sk_pr_num := '';

        for wsp_sk_prs in csr_wsp_occ_sk_prs(wsp_occ_rec.occ_cat)
        loop
            l_sk_pr_num := l_sk_pr_num || ', ' || wsp_sk_prs.sk_pr_num;
        end loop;

        l_sk_pr_num := substr(l_sk_pr_num, 3);

        for wsp_per_rec in csr_wsp_occ_recs(wsp_occ_rec.occ_cat)
        loop
            if wsp_per_rec.race = '02' --African
            then
                if wsp_per_rec.sex = 'M'
                then
                    l_ma := l_ma + 1;
                else
                    l_fa := l_fa + 1;
                end if;

                if wsp_per_rec.disability = 'Y'
                then
                    l_da := l_da + 1;
                end if;

            elsif wsp_per_rec.race = '03' --Coloured
            then
                if wsp_per_rec.sex = 'M'
                then
                    l_mc := l_mc + 1;
                else
                    l_fc := l_fc + 1;
                end if;

                if wsp_per_rec.disability = 'Y'
                then
                    l_dc := l_dc + 1;
                end if;

            elsif wsp_per_rec.race = '01' --Indian
            then
                if wsp_per_rec.sex = 'M'
                then
                    l_mi := l_mi + 1;
                else
                    l_fi := l_fi + 1;
                end if;

                if wsp_per_rec.disability = 'Y'
                then
                    l_di := l_di + 1;
                end if;

            elsif wsp_per_rec.race = '04'  --White
            then
                if wsp_per_rec.sex = 'M'
                then
                    l_mw := l_mw + 1;
                else
                    l_fw := l_fw + 1;
                end if;

                if wsp_per_rec.disability = 'Y'
                then
                    l_dw := l_dw + 1;
                end if;
            end if;
        end loop;

        l_mt := l_ma + l_mc + l_mi + l_mw;
        l_ft := l_fa + l_fc + l_fi + l_fw;
        l_dt := l_da + l_dc + l_di + l_dw;

        l_wsp_ma_sum	:= l_wsp_ma_sum	+	 l_ma;
				l_wsp_fa_sum  := l_wsp_fa_sum +  l_fa;
				l_wsp_da_sum  := l_wsp_da_sum +  l_da;

				l_wsp_mc_sum  := l_wsp_mc_sum +  l_mc;
				l_wsp_fc_sum  := l_wsp_fc_sum +  l_fc;
				l_wsp_dc_sum  := l_wsp_dc_sum +  l_dc;

				l_wsp_mi_sum  := l_wsp_mi_sum +  l_mi;
				l_wsp_fi_sum  := l_wsp_fi_sum +  l_fi;
				l_wsp_di_sum  := l_wsp_di_sum +  l_di;

				l_wsp_mw_sum  := l_wsp_mw_sum +  l_mw;
				l_wsp_fw_sum  := l_wsp_fw_sum +  l_fw;
				l_wsp_dw_sum  := l_wsp_dw_sum +  l_dw;

				l_wsp_mt_sum  := l_wsp_mt_sum +  l_mt;
				l_wsp_ft_sum  := l_wsp_ft_sum +  l_ft;
				l_wsp_dt_sum  := l_wsp_dt_sum +  l_dt;


--      Update Beneficiary details to xml dom
        update_dom('BENEFICIARIRY_DETAILS', null, g_wsp_benf_level);

        update_dom('OCCUPATION'         , wsp_occ_rec.occ_cat, g_wsp_benf_det_level);
        update_dom('PRIORITY_NUMBER'    , l_sk_pr_num        , g_wsp_benf_det_level);

        update_dom('MALE_AFRICANS'     , l_ma, g_wsp_benf_det_level);
        update_dom('FEMALE_AFRICANS'   , l_fa, g_wsp_benf_det_level);
        update_dom('DISABILED_AFRICANS', l_da, g_wsp_benf_det_level);

        update_dom('MALE_COLOUREDS'     , l_mc, g_wsp_benf_det_level);
        update_dom('FEMALE_COLOUREDS'   , l_fc, g_wsp_benf_det_level);
        update_dom('DISABILED_COLOUREDS', l_dc, g_wsp_benf_det_level);

        update_dom('MALE_INDIANS'     , l_mi, g_wsp_benf_det_level);
        update_dom('FEMALE_INDIANS'   , l_fi, g_wsp_benf_det_level);
        update_dom('DISABILED_INDIANS', l_di, g_wsp_benf_det_level);

        update_dom('MALE_WHITES'     , l_mw, g_wsp_benf_det_level);
        update_dom('FEMALE_WHITES'   , l_fw, g_wsp_benf_det_level);
        update_dom('DISABILED_WHITES', l_dw, g_wsp_benf_det_level);

        update_dom('MALE_TOTALS'     , l_mt, g_wsp_benf_det_level);
        update_dom('FEMALE_TOTALS'   , l_ft, g_wsp_benf_det_level);
        update_dom('DISABILED_TOTALS', l_dt, g_wsp_benf_det_level);
    end loop;
    --
    hr_utility.set_location ('MALE_AFRICANS_TOT :',10);
    update_dom('MALE_AFRICANS_TOT'      , l_wsp_ma_sum, g_wsp_benf_level);
    hr_utility.set_location ('MALE_AFRICANS_TOT :',20);
    update_dom('FEMALE_AFRICANS_TOT'    , l_wsp_fa_sum, g_wsp_benf_level);
    update_dom('DISABILED_AFRICANS_TOT' , l_wsp_da_sum, g_wsp_benf_level);

    update_dom('MALE_COLOUREDS_TOT'     , l_wsp_mc_sum, g_wsp_benf_level);
    update_dom('FEMALE_COLOUREDS_TOT'   , l_wsp_fc_sum, g_wsp_benf_level);
    update_dom('DISABILED_COLOUREDS_TOT', l_wsp_dc_sum, g_wsp_benf_level);

    update_dom('MALE_INDIANS_TOT'       , l_wsp_mi_sum, g_wsp_benf_level);
    update_dom('FEMALE_INDIANS_TOT'     , l_wsp_fi_sum, g_wsp_benf_level);
    update_dom('DISABILED_INDIANS_TOT'  , l_wsp_di_sum, g_wsp_benf_level);

    update_dom('MALE_WHITES_TOT'        , l_wsp_mw_sum, g_wsp_benf_level);
    update_dom('FEMALE_WHITES_TOT'      , l_wsp_fw_sum, g_wsp_benf_level);
    update_dom('DISABILED_WHITES_TOT'   , l_wsp_dw_sum, g_wsp_benf_level);

    update_dom('MALE_TOTALS_TOT'        , l_wsp_mt_sum, g_wsp_benf_level);
    update_dom('FEMALE_TOTALS_TOT'      , l_wsp_ft_sum, g_wsp_benf_level);
    update_dom('DISABILED_TOTALS_TOT'   , l_wsp_dt_sum, g_wsp_benf_level);


    hr_utility.set_location('Leaving ' || l_proc, 10);
	--	hr_utility.trace_off;
end update_wsp_data;
--

/*--------------------------------------------------------------------------
  Name      : update_atr_data
  Purpose   : Updates ATR(Training and Beneficiary) data to XML DOM.
              Assumes g_xml_dom is already initialized.
  Arguments :
--------------------------------------------------------------------------*/
procedure update_atr_data( p_legal_entity_id     in number
                         , p_payroll_action_id     in varchar2) is

l_proc     varchar2(100) := g_package || 'update_atr_data';

cursor csr_atr_trng is
    select action_information3    sk_num              -- Skills priority number (i.e serial number)
         , action_information4    training_priority   -- Skills priority ( Education/ Training priority)
         , action_information5    lev_1
         , action_information6    lev_2
         , action_information7    lev_3
         , action_information8    lev_4
         , action_information9    lev_5
         , action_information10   lev_6
         , action_information11   lev_7
         , action_information12   lev_8
         , action_information13   unknown
         , action_information14   saqa_yes
         , action_information15   saqa_no
         , action_information16   saqa_id
         , action_information17   year
      from pay_action_information
     where action_context_id           = p_payroll_action_id
       and action_information_category = 'ZA ATR TRAINING PROGRAMS'
       and action_information2         = p_legal_entity_id
       and action_context_type         = 'PA'
       order by sk_num;

cursor csr_atr_occ is
    select action_information6       occ_cat
      from  pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where ppa.payroll_action_id           = p_payroll_action_id
       AND paa.payroll_action_id           = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA ATR PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
     group by pai.action_information6;

cursor csr_atr_occ_recs( p_occ_cat  varchar) is
    select distinct pai.action_information3 person_id
    		 , action_information4   race
         , action_information5   sex
         , action_information7   disability
         , action_information14  status
      from pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where ppa.payroll_action_id           = p_payroll_action_id
       AND paa.payroll_action_id           = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA ATR PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
       and pai.action_information6         = p_occ_cat;

cursor csr_atr_occ_sk_prs( p_occ_cat  varchar) is
    select distinct action_information11   sk_pr_num
      from pay_payroll_actions ppa
         , pay_assignment_actions paa
         , pay_action_information pai
     where ppa.payroll_action_id           = p_payroll_action_id
       AND paa.payroll_action_id           = ppa.payroll_action_id
       AND pai.action_context_id           = paa.assignment_action_id
       and pai.action_information_category = 'ZA ATR PERSON DETAILS'
       and pai.action_information2         = p_legal_entity_id
       and pai.action_context_type         = 'AAP'
       and pai.action_information6         = p_occ_cat
       order by sk_pr_num;

-- For Attended
l_ma    number(15);
l_fa    number(15);
l_da    number(15);

l_mc    number(15);
l_fc    number(15);
l_dc    number(15);

l_mi    number(15);
l_fi    number(15);
l_di    number(15);

l_mw    number(15);
l_fw    number(15);
l_dw    number(15);

l_mt    number(15);
l_ft    number(15);
l_dt    number(15);

-- For Completed
l_cma    number(15);
l_cfa    number(15);
l_cda    number(15);

l_cmc    number(15);
l_cfc    number(15);
l_cdc    number(15);

l_cmi    number(15);
l_cfi    number(15);
l_cdi    number(15);

l_cmw    number(15);
l_cfw    number(15);
l_cdw    number(15);

l_cmt    number(15);
l_cft    number(15);
l_cdt    number(15);
--For Grand Totals
l_ma_sum				number(15) := 0;
l_fa_sum        number(15) := 0;
l_da_sum        number(15) := 0;

l_mc_sum        number(15) := 0;
l_fc_sum        number(15) := 0;
l_dc_sum        number(15) := 0;

l_mi_sum        number(15) := 0;
l_fi_sum        number(15) := 0;
l_di_sum        number(15) := 0;

l_mw_sum        number(15) := 0;
l_fw_sum        number(15) := 0;
l_dw_sum        number(15) := 0;

l_mt_sum        number(15) := 0;
l_ft_sum        number(15) := 0;
l_dt_sum        number(15) := 0;


l_sk_pr_num varchar2(2000);

begin
    hr_utility.set_location ('Entering ' || l_proc, 10);


--  Create parent node for ATR data
    update_dom('ATR', null, g_atr_level);

-- Update ATR Training Details
    for atr_trng_rec in csr_atr_trng
    loop
        update_dom('TRAINING_DETAILS', null, g_atr_trng_level);

        update_dom('SK_NUM'           , atr_trng_rec.sk_num           , g_atr_trng_det_level);
        update_dom('TRAINING_PRIORITY', atr_trng_rec.training_priority, g_atr_trng_det_level);
        update_dom('LEV_1'          , atr_trng_rec.lev_1            , g_atr_trng_det_level);
        update_dom('LEV_2'          , atr_trng_rec.lev_2            , g_atr_trng_det_level);
        update_dom('LEV_3'          , atr_trng_rec.lev_3            , g_atr_trng_det_level);
        update_dom('LEV_4'          , atr_trng_rec.lev_4            , g_atr_trng_det_level);
        update_dom('LEV_5'          , atr_trng_rec.lev_5            , g_atr_trng_det_level);
        update_dom('LEV_6'          , atr_trng_rec.lev_6            , g_atr_trng_det_level);
        update_dom('LEV_7'          , atr_trng_rec.lev_7            , g_atr_trng_det_level);
        update_dom('LEV_8'          , atr_trng_rec.lev_8            , g_atr_trng_det_level);
        update_dom('UNKNOWN'          , atr_trng_rec.unknown          , g_atr_trng_det_level);
        update_dom('SAQA_YES'         , atr_trng_rec.saqa_yes         , g_atr_trng_det_level);
        update_dom('SAQA_NO'          , atr_trng_rec.saqa_no          , g_atr_trng_det_level);
        update_dom('SAQA_ID'          , atr_trng_rec.saqa_id          , g_atr_trng_det_level);
    end loop;

--  Update ATR Beneficiary details
    for atr_occ_rec in csr_atr_occ
    loop
        l_ma := 0; l_fa := 0; l_da := 0;
        l_mc := 0; l_fc := 0; l_dc := 0;
        l_mi := 0; l_fi := 0; l_di := 0;
        l_mw := 0; l_fw := 0; l_dw := 0;
        l_mt := 0; l_ft := 0; l_dt := 0;

        l_cma := 0; l_cfa := 0; l_cda := 0;
        l_cmc := 0; l_cfc := 0; l_cdc := 0;
        l_cmi := 0; l_cfi := 0; l_cdi := 0;
        l_cmw := 0; l_cfw := 0; l_cdw := 0;
        l_cmt := 0; l_cft := 0; l_cdt := 0;

        l_sk_pr_num := '';

        for atr_sk_prs in csr_atr_occ_sk_prs(atr_occ_rec.occ_cat)
        loop
            l_sk_pr_num := l_sk_pr_num || ', ' || atr_sk_prs.sk_pr_num;
        end loop;

        l_sk_pr_num := substr(l_sk_pr_num, 3);

        for atr_per_rec in csr_atr_occ_recs(atr_occ_rec.occ_cat)
        loop
            if atr_per_rec.race = '02' --African
            then
                if atr_per_rec.sex = 'M'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_ma := l_ma + 1;
                    else
                        l_cma := l_cma + 1;
                    end if;
                else
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_fa := l_fa + 1;
                    else
                        l_cfa := l_cfa + 1;
                    end if;
                end if;

                if atr_per_rec.disability = 'Y'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_da := l_da + 1;
                    else
                        l_cda := l_cda + 1;
                    end if;
                end if;

            elsif atr_per_rec.race = '03' -- Coloured
            then
                if atr_per_rec.sex = 'M'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_mc := l_mc + 1;
                    else
                        l_cmc := l_cmc + 1;
                    end if;
                else
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_fc := l_fc + 1;
                    else
                        l_cfc := l_cfc + 1;
                    end if;
                end if;

                if atr_per_rec.disability = 'Y'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_dc := l_dc + 1;
                    else
                        l_cdc := l_cdc + 1;
                    end if;
                end if;

            elsif atr_per_rec.race = '01'  -- Indian
            then
                if atr_per_rec.sex = 'M'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_mi := l_mi + 1;
                    else
                        l_cmi := l_cmi + 1;
                    end if;
                else
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_fi := l_fi + 1;
                    else
                        l_cfi := l_cfi + 1;
                    end if;
                end if;

                if atr_per_rec.disability = 'Y'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_di := l_di + 1;
                    else
                        l_cdi := l_cdi + 1;
                    end if;
                end if;

            elsif atr_per_rec.race = '04'		--White
            then
                if atr_per_rec.sex = 'M'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_mw := l_mw + 1;
                    else
                        l_cmw := l_cmw + 1;
                    end if;
                else
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_fw := l_fw + 1;
                    else
                        l_cfw := l_cfw + 1;
                    end if;
                end if;

                if atr_per_rec.disability = 'Y'
                then
                    if atr_per_rec.status = 'ATTENDED'
                    then
                        l_dw := l_dw + 1;
                    else
                        l_cdw := l_cdw + 1;
                    end if;
                end if;
            end if;
        end loop;

-- Attended Totals
        l_mt := l_ma + l_mc + l_mi + l_mw;
        l_ft := l_fa + l_fc + l_fi + l_fw;
        l_dt := l_da + l_dc + l_di + l_dw;

-- Completed Totals
        l_cmt := l_cma + l_cmc + l_cmi + l_cmw;
        l_cft := l_cfa + l_cfc + l_cfi + l_cfw;
        l_cdt := l_cda + l_cdc + l_cdi + l_cdw;

--For Grand Totals
				l_ma_sum :=	l_ma_sum	+	 l_ma		+ l_cma;
				l_fa_sum := l_fa_sum  +  l_fa   + l_cfa;
				l_da_sum := l_da_sum  +  l_da   + l_cda;

				l_mc_sum := l_mc_sum  +  l_mc   + l_cmc;
				l_fc_sum := l_fc_sum  +  l_fc   + l_cfc;
				l_dc_sum := l_dc_sum  +  l_dc   + l_cdc;

				l_mi_sum := l_mi_sum  +  l_mi   + l_cmi;
				l_fi_sum := l_fi_sum  +  l_fi   + l_cfi;
				l_di_sum := l_di_sum  +  l_di   + l_cdi;

				l_mw_sum := l_mw_sum  +  l_mw   + l_cmw;
				l_fw_sum := l_fw_sum  +  l_fw   + l_cfw;
				l_dw_sum := l_dw_sum  +  l_dw   + l_cdw;

				l_mt_sum := l_mt_sum  +  l_mt   + l_cmt;
				l_ft_sum := l_ft_sum  +  l_ft   + l_cft;
				l_dt_sum := l_dt_sum  +  l_dt   + l_cdt;


--      Update Beneficiary details to xml dom
        update_dom('BENEFICIARIRY_DETAILS', null, g_atr_benf_level);

        update_dom('OCCUPATION'         , atr_occ_rec.occ_cat, g_atr_benf_det_level);
        update_dom('PRIORITY_NUMBER'    , l_sk_pr_num        , g_atr_benf_det_level);

-- Attended person details
        update_dom('MALE_AFRICANS'     , l_ma, g_atr_benf_det_level);
        update_dom('FEMALE_AFRICANS'   , l_fa, g_atr_benf_det_level);
        update_dom('DISABILED_AFRICANS', l_da, g_atr_benf_det_level);

        update_dom('MALE_COLOUREDS'     , l_mc, g_atr_benf_det_level);
        update_dom('FEMALE_COLOUREDS'   , l_fc, g_atr_benf_det_level);
        update_dom('DISABILED_COLOUREDS', l_dc, g_atr_benf_det_level);

        update_dom('MALE_INDIANS'     , l_mi, g_atr_benf_det_level);
        update_dom('FEMALE_INDIANS'   , l_fi, g_atr_benf_det_level);
        update_dom('DISABILED_INDIANS', l_di, g_atr_benf_det_level);

        update_dom('MALE_WHITES'     , l_mw, g_atr_benf_det_level);
        update_dom('FEMALE_WHITES'   , l_fw, g_atr_benf_det_level);
        update_dom('DISABILED_WHITES', l_dw, g_atr_benf_det_level);

        update_dom('MALE_TOTALS'     , l_mt, g_atr_benf_det_level);
        update_dom('FEMALE_TOTALS'   , l_ft, g_atr_benf_det_level);
        update_dom('DISABILED_TOTALS', l_dt, g_atr_benf_det_level);

-- Completed person details
        update_dom('MALE_AFRICANS_COMP'     , l_cma, g_atr_benf_det_level);
        update_dom('FEMALE_AFRICANS_COMP'   , l_cfa, g_atr_benf_det_level);
        update_dom('DISABILED_AFRICANS_COMP', l_cda, g_atr_benf_det_level);

        update_dom('MALE_COLOUREDS_COMP'     , l_cmc, g_atr_benf_det_level);
        update_dom('FEMALE_COLOUREDS_COMP'   , l_cfc, g_atr_benf_det_level);
        update_dom('DISABILED_COLOUREDS_COMP', l_cdc, g_atr_benf_det_level);

        update_dom('MALE_INDIANS_COMP'     , l_cmi, g_atr_benf_det_level);
        update_dom('FEMALE_INDIANS_COMP'   , l_cfi, g_atr_benf_det_level);
        update_dom('DISABILED_INDIANS_COMP', l_cdi, g_atr_benf_det_level);

        update_dom('MALE_WHITES_COMP'     , l_cmw, g_atr_benf_det_level);
        update_dom('FEMALE_WHITES_COMP'   , l_cfw, g_atr_benf_det_level);
        update_dom('DISABILED_WHITES_COMP', l_cdw, g_atr_benf_det_level);

        update_dom('MALE_TOTALS_COMP'     , l_cmt, g_atr_benf_det_level);
        update_dom('FEMALE_TOTALS_COMP'   , l_cft, g_atr_benf_det_level);
        update_dom('DISABILED_TOTALS_COMP', l_cdt, g_atr_benf_det_level);

    end loop;
-- for grand totals
    update_dom('MALE_AFRICANS_TOT'      , l_ma_sum, g_atr_benf_level);
    update_dom('FEMALE_AFRICANS_TOT'    , l_fa_sum, g_atr_benf_level);
    update_dom('DISABILED_AFRICANS_TOT' , l_da_sum, g_atr_benf_level);

    update_dom('MALE_COLOUREDS_TOT'     , l_mc_sum, g_atr_benf_level);
    update_dom('FEMALE_COLOUREDS_TOT'   , l_fc_sum, g_atr_benf_level);
    update_dom('DISABILED_COLOUREDS_TOT', l_dc_sum, g_atr_benf_level);

    update_dom('MALE_INDIANS_TOT'       , l_mi_sum, g_atr_benf_level);
    update_dom('FEMALE_INDIANS_TOT'     , l_fi_sum, g_atr_benf_level);
    update_dom('DISABILED_INDIANS_TOT'  , l_di_sum, g_atr_benf_level);

    update_dom('MALE_WHITES_TOT'        , l_mw_sum, g_atr_benf_level);
    update_dom('FEMALE_WHITES_TOT'      , l_fw_sum, g_atr_benf_level);
    update_dom('DISABILED_WHITES_TOT'   , l_dw_sum, g_atr_benf_level);

    update_dom('MALE_TOTALS_TOT'        , l_mt_sum, g_atr_benf_level);
    update_dom('FEMALE_TOTALS_TOT'      , l_ft_sum, g_atr_benf_level);
    update_dom('DISABILED_TOTALS_TOT'   , l_dt_sum, g_atr_benf_level);

    hr_utility.set_location('Leaving ' || l_proc, 10);

end update_atr_data;
--

/*--------------------------------------------------------------------------
  Name      : populate_xml_data
  Purpose   : Populates XML data as CLOB for WSP report
  Arguments : p_xml -> out variable
--------------------------------------------------------------------------*/
procedure populate_xml_data ( p_business_group_id     in number
                            , p_payroll_action_id     in varchar2
                            , p_legal_entity_id       in number
                            , p_template_name         IN VARCHAR2
                            , p_xml                   out nocopy clob) is

l_proc           varchar2(100) := g_package || 'populate_xml_data';

main_node    xmldom.DOMNode;
root_node    xmldom.DOMNode;
parent_node  xmldom.DOMNode;
item_node    xmldom.DOMNode;

root_elmt    xmldom.DOMElement;
item_elmt    xmldom.DOMElement;
item_text    xmldom.DOMText;

cursor csr_legal_entities is
    select distinct action_information2  legal_entity_id -- Legal entity ID
      from pay_action_information
     where action_context_id           = p_payroll_action_id
       and action_information1         = p_business_group_id
       and action_information2         = nvl(p_legal_entity_id, action_information2)
       and action_information_category = 'ZA WSP EMPLOYER DETAILS'
       and action_context_type         = 'PA';

begin
--   hr_utility.trace_on(null, 'WSP_GEN');
    hr_utility.set_location ('Entering ' || l_proc, 10);

--  Initialize g_xml_dom and create root node
    g_xml_dom := xmldom.newDOMDocument;
    main_node := xmldom.makeNode(g_xml_dom);
    root_elmt := xmldom.createElement(g_xml_dom, 'ZA_WSP_ATR_ROOT');
    root_node := xmldom.appendChild(main_node, xmldom.makeNode(root_elmt));
    g_node_list(g_root_level) := root_node;

    for rec in csr_legal_entities
    loop
        update_dom('ZA_WSP_ATR_DATA', null, g_root_level);

    --  Update all company level data to g_xml_dom
        update_company_data(rec.legal_entity_id, p_payroll_action_id);

    --  Update WSP Training and Beneficiary details
        update_wsp_data(rec.legal_entity_id, p_payroll_action_id);

    --  Update ATR Training and Beneficiary details
        update_atr_data(rec.legal_entity_id, p_payroll_action_id);
    end loop;

--  Update out variable p_xml and release xml dom
    dbms_lob.createtemporary(p_xml, true);
    xmldom.writeToClob(g_xml_dom, p_xml);
    xmldom.freeDocument(g_xml_dom);
		-- open the file p_xml
		-- Why ? In the Core wrapper package(PAY_XML_GEN_PKG) this is being closed
		dbms_lob.open(p_xml, dbms_lob.lob_readonly);

    hr_utility.set_location('Leaving ' || l_proc, 10);

  -- hr_utility.trace_off;

end populate_xml_data;

end PER_ZA_WSP_XML_GEN_PKG;


/
