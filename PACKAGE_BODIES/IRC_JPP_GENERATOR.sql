--------------------------------------------------------
--  DDL for Package Body IRC_JPP_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_JPP_GENERATOR" as
/* $Header: irjppgen.pkb 120.15.12010000.4 2010/05/05 13:23:34 amikukum ship $ */

procedure generateJPPint(p_recruitment_activity_id in number
                        ,p_sender_id in number
                        ,p_stylesheet varchar2 default null
                        ,p_jpp_doc out nocopy clob) is
l_query varchar2(32767);
l_jpp_doc CLOB;
lv_stylesheet varchar2(32767);
l_stylesheet_url varchar2(2000);
stylesheetdoc xmldom.DOMDocument;
stylesheet xslprocessor.Stylesheet;
engine xslprocessor.Processor;
parser xmlparser.parser;
xmldoc xmldom.DOMDocument;
clobdoc CLOB;
ctx DBMS_XMLQUERY.ctxType;
tv_sheet utl_http.html_pieces;
l_index number;
begin
l_query:=  'select hr_xml_packet_id_s.nextval packetId'
        ||' , ''CREATE'' action'
        ||' , hr_xml_transaction_id_s.nextval transactionid'
        ||' , translate(to_char(sysdate,''RRRR-MM-DD HH:MM:SS''),'' '',''T'') timestamp'
        ||' , rse.posting_url vendorURL'
        ||' , decode(rse.posting_username '
        ||'   ,''#USERID'',to_char(sndr_usr.user_id) '
        ||'   ,''#USERNAME'',sndr_usr.user_name '
        ||'   ,''#EMAIL'',nvl(sndr_per.email_address,sndr_usr.email_address)'
        ||'   , rse.posting_username) posting_username'
        ||' , decode(fnd_vault.get(''IRC_SITE'',rse.recruiting_site_id )'
        ||'   ,''#USERID'',to_char(sndr_usr.user_id) '
        ||'   ,''#USERNAME'',sndr_usr.user_name '
        ||'   ,''#EMAIL'',nvl(sndr_per.email_address,sndr_usr.email_address)'
        ||'   , fnd_vault.get(''IRC_SITE'',rse.recruiting_site_id) )posting_password'
        ||' , rse.stylesheet '
        ||' , sndr_per.last_name personlastname'
        ||' , sndr_per.first_name personfirstname'
        ||' , sndr_per.email_address emailaddress'
        ||' , sndr_usr.user_id userid'
        ||' , recr_pp.first_name recr_first_name'
        ||' , recr_pp.last_name recr_last_name'
        ||' , recr_pp.full_name recr_full_name'
        ||' , recr_pp.email_address recr_email_address'
        ||' , recr_phn.phone_number recr_phone_number'
        ||' , recr_phn_fax.phone_number recr_fax_number'
        ||' , recr_pp.person_id recr_person_id'
        ||' , vac.number_of_openings'
        ||' , vac.name vacancy_name'
        ||' , vac.budget_measurement_type'
        ||' , vac.budget_measurement_value'
        ||' , to_char(vac.date_from,''RRRR-MM-DD'') vacancy_start_date'
        ||' , to_char(vac.date_to,''RRRR-MM-DD'') vacancy_end_date'
        ||' , rtrim(nvl(fnd_profile.value(''IRC_FRAMEWORK_AGENT'')'
        ||' ,fnd_profile.value(''APPS_FRAMEWORK_AGENT''))||'
        ||' fnd_profile.value(''ICX_PREFIX''),''/'')||''/OA_HTML/OA.jsp?OAFunc=''||'
        ||' fnd_profile.value(''IRC_JOB_NOTIFICATION_URL'')||'
        ||' ''&amp;p_svid=''||to_char(vac.vacancy_id)||'
        ||' ''&amp;p_spid=''||to_char(ipc.posting_content_id)||';
        if(HR_MULTI_TENANCY_PKG.is_multi_tenant_system()) then
             l_query:=l_query ||' ''&amp;OAMC=''||to_char(''R'')||' ;
        end if;
        l_query := l_query
        ||' ''&amp;p_site_id=''||to_char(rse.recruiting_site_id) application_url'
        ||' , rtrim(fnd_profile.value(''APPS_FRAMEWORK_AGENT'')||'
        ||' fnd_profile.value(''ICX_PREFIX''),''/'')||''/OA_HTML/OA.jsp?OAFunc=''||'
        ||' fnd_profile.value(''IRC_JOB_NOTIFICATION_URL'')||'
        ||' ''&amp;p_svid=''||to_char(vac.vacancy_id)||'
        ||' ''&amp;p_spid=''||to_char(ipc.posting_content_id)||'
        ||' ''&amp;p_site_id=''||to_char(rse.recruiting_site_id) int_application_url'
        ||' , irc_isc.object_id'
        ||' , hr_general.decode_lookup(''IRC_PROFESSIONAL_AREA'',irc_isc.professional_area) professional_area'
        ||' , irc_isc.employee'
        ||' , irc_isc.contractor'
        ||' , irc_isc.employment_category'
        ||' , irc_isc.min_salary'
        ||' , irc_isc.max_salary'
        ||' , nvl(irc_isc.max_salary,irc_isc.min_salary) salary'
        ||' , irc_isc.salary_currency'
        ||' , irc_isc.salary_period'
        ||' , irc_isc.travel_percentage'
        ||' , decode(irc_isc.employment_category,''EITHER'',''Y'',''FULLTIME'',''Y'',''PARTTIME'',''N'',''Y'') full_time'
        ||' , decode(irc_isc.employment_category,''EITHER'',''Y'',''PARTTIME'',''Y'',''FULLTIME'',''N'',''Y'') part_time'
        ||' , ipc.display_recruiter_info'
        ||' , ipctl.posting_content_id'
        ||' , ipctl.name'
        ||' , ipctl.org_name'
        ||' , replace(replace(ipctl.org_description,''&'',''&''||''amp;''),''<'',''&''||''lt;'') org_description'
        ||' , nvl(ipctl.job_title,ipctl.name) job_title'
        ||' , replace(replace(ipctl.brief_description,''&'',''&''||''amp;''),''<'',''&''||''lt;'') brief_description'
        ||' , replace(replace(ipctl.detailed_description,''&'',''&''||''amp;''),''<'',''&''||''lt;'') detailed_description'
        ||' , replace(replace(ipctl.job_requirements,''&'',''&''||''amp;''),''<'',''&''||''lt;'') job_requirements'
        ||' , replace(replace(ipctl.additional_details,''&'',''&''||''amp;''),''<'',''&''||''lt;'') additional_details'
        ||' , replace(replace(ipctl.how_to_apply,''&'',''&''||''amp;''),''<'',''&''||''lt;'') how_to_apply'
        ||' , replace(replace(ipctl.benefit_info,''&'',''&''||''amp;''),''<'',''&''||''lt;'') benefit_info'
        ||' , rec.recruitment_activity_id'
        ||' , to_char(rec.date_start,''RRRR-MM-DD'') posting_start_date'
        ||' , to_char(rec.date_end,''RRRR-MM-DD'') posting_end_date'
        ||' , loc.address_line_1'
        ||' , loc.address_line_2'
        ||' , loc.address_line_3'
        ||' , loc.town_or_city'
        ||' , loc.country'
        ||' , loc.postal_code'
        ||' , loc.region_1'
        ||' , loc.region_2'
        ||' , loc.region_3'
    -- cursor to get the details of the competences/skills for the position
        ||' , cursor (select pc.name '
        ||'                , pce.mandatory '
        ||'                , pc.competence_id '
        ||'                , pce.competence_element_id '
        ||'                , prl1.step_value min_level_id '
        ||'                , prl2.step_value max_level_id '
        ||'                , prl1.name min_level '
        ||'                , prl2.name max_level'
        ||'             from per_competences_tl pc'
        ||'                , per_competence_elements pce'
        ||'                , per_rating_levels prl1'
        ||'                , per_rating_levels prl2'
        ||'             where  pc.language=ipctl.source_language'
        ||'               and pc.competence_id = pce.competence_id '
        ||'               and pce.type = ''REQUIREMENT'''
        ||'               and pce.object_name = ''VACANCY'''
        ||'               and pce.object_id = vac.vacancy_id'
        ||'               and prl1.rating_level_id(+) = pce.proficiency_level_id'
        ||'               and prl2.rating_level_id(+) = pce.high_proficiency_level_id'
        ||'               and vac.date_from '
        ||'                between nvl(pce.effective_date_from, vac.date_from)'
        ||'                   and nvl(pce.effective_date_to, vac.date_from)'
        ||'           ORDER BY pce.mandatory, pc.name DESC'
        ||'           ) competences'
-- cursor to get the variable comp element
        ||'   , cursor (select meaning var_comp from fnd_lookup_values_vl where lookup_type=''IRC_VARIABLE_COMP_ELEMENT'''
        ||'             and lookup_code in ( select variable_comp_lookup vce from irc_variable_comp_elements vce where  vac.vacancy_id = vce.vacancy_id)'
        ||'            ) comp_elements'
        ||' from  irc_posting_contents_tl ipctl'
        ||'    ,  irc_posting_contents ipc'
        ||'    ,  per_recruitment_activities rec'
        ||'    ,  per_recruitment_activity_for recf'
        ||'    ,  per_all_vacancies vac'
        ||'    ,  hr_locations_all_vl loc'
        ||'    ,  irc_search_criteria irc_isc'
        ||'    ,  irc_all_recruiting_sites rse'
        ||'    ,  fnd_user sndr_usr'
        ||'    ,  per_all_people_f   sndr_per'
        ||'    ,  per_all_people_f recr_pp'
        ||'    ,  per_phones recr_phn'
        ||'    ,  per_phones recr_phn_fax'
        ||' where rec.recruitment_activity_id=:1'
        ||'   and recf.vacancy_id = vac.vacancy_id'
        ||'   and not exists (select 1 from per_recruitment_activity_for recf2'
        ||'   where recf2.recruitment_activity_id =rec.recruitment_activity_id'
        ||'   and recf2.recruitment_activity_for_id>recf.recruitment_activity_for_id)'
        ||'   and rec.recruitment_activity_id = recf.recruitment_activity_id'
        ||'   and ipc.posting_content_id = rec.posting_content_id'
        ||'   and ipctl.posting_content_id = ipc.posting_content_id '
        ||'   and ipctl.source_language = userenv(''LANG'')'
        ||'   and rse.recruiting_site_id = rec.recruiting_site_id'
        ||'   and sndr_usr.user_id = :2'
        ||'   and sndr_usr.employee_id=sndr_per.person_id'
        ||'   and trunc(sysdate)'
        ||'       between sndr_per.effective_start_date and '
        ||'       sndr_per.effective_end_date'
        ||'   and vac.recruiter_id = recr_pp.person_id(+) '
        ||'   and vac.recruiter_id = recr_phn.parent_id(+) '
        ||'   and recr_phn.parent_table(+) = ''PER_ALL_PEOPLE_F'''
        ||'   and recr_phn.phone_type(+) = ''W1'''
        ||'   and vac.recruiter_id = recr_phn_fax.parent_id(+) '
        ||'   and recr_phn_fax.parent_table(+) = ''PER_ALL_PEOPLE_F'''
        ||'   and recr_phn_fax.phone_type(+) = ''WF'''
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_pp.effective_start_date,trunc(sysdate)) '
        ||'       and nvl(recr_pp.effective_end_date,trunc(sysdate))'
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_phn.date_from,trunc(sysdate))  '
        ||'       and nvl(recr_phn.date_to, trunc(sysdate)) '
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_phn_fax.date_from,trunc(sysdate))  '
        ||'       and nvl(recr_phn_fax.date_to, trunc(sysdate)) '
        ||'   and vac.location_id = loc.location_id (+)'
        ||'   and vac.vacancy_id = irc_isc.object_id (+)'
        ||'   and irc_isc.object_type(+) = ''VACANCY'''
        ||'   and rownum=1';

  if (p_stylesheet is null) then

lv_stylesheet:='<?xml version="1.0" ?>'||
'<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'||
'<xsl:output  method="xml" indent="yes" doctype-system="Envelope-v01-00.dtd"/>'||
'<xsl:template match="JobPositionPosting">'||
'<xsl:for-each select="row">&'||'lt;?xml version = "1.0"?>
';
if(p_stylesheet is null) then
  lv_stylesheet:=lv_stylesheet||'&'||'lt;!DOCTYPE Envelope SYSTEM "ProvisionalEnvelope-v1.0.dtd">
';
end if;
lv_stylesheet:=lv_stylesheet||
'&'||'lt;Envelope version = "01.00">'||
'&'||'lt;Sender>'||
'&'||'lt;Id><xsl:value-of select="posting_username "/>&'||'lt;/Id>'||
'&'||'lt;Credential><xsl:value-of select="posting_password "/>&'||'lt;/Credential>'||
'&'||'lt;/Sender>'||
'&'||'lt;Recipient>'||
'&'||'lt;Id><xsl:value-of select="vendorurl"/>&'||'lt;/Id>'||
'&'||'lt;/Recipient>'||
'&'||'lt;TransactInfo transactType = "request">'||
'&'||'lt;TransactId><xsl:value-of select="transactionid"/>&'||'lt;/TransactId>'||
'&'||'lt;TimeStamp><xsl:value-of select="timestamp"/>&'||'lt;/TimeStamp>'||
'&'||'lt;/TransactInfo>'||
'&'||'lt;Packet>'||
'&'||'lt;PacketInfo packetType = "request">'||
'&'||'lt;PacketId><xsl:value-of select="packetid"/>&'||'lt;/PacketId>'||
'&'||'lt;Action><xsl:value-of select="action"/>&'||'lt;/Action>'||
'&'||'lt;Manifest>JobPositionSeeker-1_1.dtd&'||'lt;/Manifest>'||
'&'||'lt;/PacketInfo>'||
--
--       This is the start of the ProvisionalEnvelope Payload Element.
--       This element contains the posting details in JobPositionPosting-1_1.dtd
--       complient XML
--
'&'||'lt;Payload>&'||'lt;![CDATA[&'||'lt;?xml version = "1.0"?>'||
'&'||'lt;!DOCTYPE JobPositionPosting SYSTEM "JobPositionPosting-1_1.dtd">'||
'&'||'lt;JobPositionPosting>'||
'&'||'lt;JobPositionPostingId idOwner="oracle.com"><xsl:value-of select="recruitment_activity_id"/>&'||'lt;/JobPositionPostingId>'||
'&'||'lt;HiringOrg>'||
'&'||'lt;HiringOrgName><xsl:value-of select="org_name"/>&'||'lt;/HiringOrgName>'||
'&'||'lt;Industry>'||
'&'||'lt;SummaryText><xsl:value-of select="professional_area"/>&'||'lt;/SummaryText>'||
'&'||'lt;/Industry>'||
  '<xsl:if test="display_recruiter_info=''Y'' and count(recr_person_id)!=0"> '||
  '&'||'lt;Contact>'||
  '&'||'lt;PersonName>'||
  '&'||'lt;FormattedName><xsl:value-of select="recr_full_name"/>&'||'lt;/FormattedName>'||
  '&'||'lt;GivenName><xsl:value-of select="recr_first_name"/>&'||'lt;/GivenName>'||
  '&'||'lt;FamilyName><xsl:value-of select="recr_last_name"/>&'||'lt;/FamilyName>'||
  '&'||'lt;/PersonName>'||
  '&'||'lt;VoiceNumber>'||
  '&'||'lt;TelNumber><xsl:value-of select="recr_phone_number"/>&'||'lt;/TelNumber>'||
  '&'||'lt;/VoiceNumber>'||
  '&'||'lt;FaxNumber>'||
  '&'||'lt;TelNumber><xsl:value-of select="recr_fax_number"/>&'||'lt;/TelNumber>'||
  '&'||'lt;/FaxNumber>'||
  '&'||'lt;E-mail><xsl:value-of select="recr_email_address"/>&'||'lt;/E-mail>'||
  '&'||'lt;/Contact>'||
  '</xsl:if>'||
'&'||'lt;OrganizationalUnit>'||
'&'||'lt;Description><xsl:value-of select="org_description"/>&'||'lt;/Description>'||
'&'||'lt;/OrganizationalUnit>'||
'&'||'lt;/HiringOrg>'||
'&'||'lt;PostDetail>'||
'&'||'lt;StartDate>'||
'&'||'lt;Date><xsl:value-of select="posting_start_date"/>&'||'lt;/Date>'||
'&'||'lt;/StartDate>'||
'&'||'lt;EndDate>'||
'&'||'lt;Date><xsl:value-of select="posting_end_date"/>&'||'lt;/Date>'||
'&'||'lt;/EndDate>'||
'&'||'lt;PostedBy>'||
'&'||'lt;Contact>'||
'&'||'lt;PersonName>'||
'&'||'lt;GivenName><xsl:value-of select="personfirstname"/>&'||'lt;/GivenName>'||
'&'||'lt;FamilyName><xsl:value-of select="personlastname"/>&'||'lt;/FamilyName>'||
'&'||'lt;/PersonName>'||
'&'||'lt;E-mail><xsl:value-of select="emailaddress"/>&'||'lt;/E-mail>'||
'&'||'lt;/Contact>'||
'&'||'lt;/PostedBy>'||
'&'||'lt;/PostDetail>'||
'&'||'lt;JobPositionInformation>'||
'&'||'lt;JobPositionTitle><xsl:value-of select="job_title"/>&'||'lt;/JobPositionTitle>'||
'&'||'lt;JobPositionDescription>'||
'&'||'lt;JobPositionPurpose><xsl:value-of select="detailed_description"/>&'||'lt;/JobPositionPurpose>'||
'&'||'lt;JobPositionLocation>'||
'&'||'lt;PostalAddress>'||
'&'||'lt;CountryCode><xsl:value-of select="country"/>&'||'lt;/CountryCode>'||
'&'||'lt;PostalCode><xsl:value-of select="postal_code"/> &'||'lt;/PostalCode>'||
'&'||'lt;Region><xsl:value-of select="region_1"/>&'||'lt;/Region>'||
'&'||'lt;Region><xsl:value-of select="region_2"/>&'||'lt;/Region>'||
'&'||'lt;Region><xsl:value-of select="region_3"/>&'||'lt;/Region>'||
'&'||'lt;Municipality><xsl:value-of select="town_or_city"/>&'||'lt;/Municipality>'||
'&'||'lt;DeliveryAddress>'||
'&'||'lt;AddressLine><xsl:value-of select="address_line_1"/>&'||'lt;/AddressLine>'||
'&'||'lt;AddressLine><xsl:value-of select="address_line_2"/>&'||'lt;/AddressLine>'||
'&'||'lt;AddressLine><xsl:value-of select="address_line_3"/>&'||'lt;/AddressLine>'||
'&'||'lt;/DeliveryAddress>'||
'&'||'lt;/PostalAddress>'||
'&'||'lt;/JobPositionLocation>'||
'&'||'lt;Classification>'||
--
--           The element DirectHireOrContract only allows one of the following child elements
--
--                DirectHire    Contract    Temp     TempToPerm
--
--          Oracle only use DirectHire or Contract in this element.
--
--          The DTD specifies that only one can be set, so if both are, we use DirectHire.
--          The child element has to be null.
--
  '<xsl:choose> <xsl:when test="employee=''Y'' or contractor=''Y''">'||
  '&'||'lt;DirectHireOrContract><xsl:choose>'||
    '<xsl:when test="employee=''Y''"> '||
    '&'||'lt;DirectHire>&'||'lt;/DirectHire> </xsl:when><xsl:otherwise>'||
    '&'||'lt;Contract>&'||'lt;/Contract> </xsl:otherwise></xsl:choose>'||
    '&'||'lt;/DirectHireOrContract>'||
    '</xsl:when>'||
  '</xsl:choose>'||
--
--           The Schedule Element has FullTime and PartTime child elments.
--
--          Only one can be set - so we are default to FullTime if both are set.
--          The JobPositionPosting-1_1 DTD has an error whereby both FullTime and PartTime
--          have a child element called SummaryText.  Element FullTime has this as mandatory
--          whereas element PartTime has this as optional.
--
--          For consistancy, both will assume it is mandatory.
--
  '<xsl:choose> <xsl:when test="full_time=''Y'' or part_time=''Y''">'||
  '&'||'lt;Schedule>'||
   '<xsl:choose>'||
    '<xsl:when test="full_time=''Y''"> '||
    '&'||'lt;FullTime>'||
    '&'||'lt;SummaryText><xsl:value-of select="full_time"/>&'||'lt;/SummaryText>'||
    '&'||'lt;/FullTime> </xsl:when><xsl:otherwise>'||
    '&'||'lt;PartTime>'||
    '&'||'lt;SummaryText><xsl:value-of select="part_time"/>&'||'lt;/SummaryText>'||
    '&'||'lt;/PartTime> </xsl:otherwise></xsl:choose>'||
  '&'||'lt;/Schedule>'||
  '</xsl:when> </xsl:choose>'||
'&'||'lt;/Classification>'||
  '<xsl:if test="count(salary_currency)!=0 or string-length(benefit_info)!=0 or count(comp_elements/comp_elements_row)!=0">'||
  '&'||'lt;CompensationDescription>'||
--
--             Element Pay and associated children will only be displayed if the
--            salary_currency is available.
--
--            Currently, our UI only deals with Annual values, however this xsl
--            will handle both monthly and hourly values as well.  It will default
--            to ANNUAL.  (This does mean it will have to change should the PAY_BASIS
--            lookup code PERIOD ever be used.
--
    '<xsl:if test="count(salary_currency)!=0"> &'||'lt;Pay><xsl:choose>'||
    '<!-- Default to ANNUAL as we only really use this -->'||
      '<xsl:when test="salary_period=''MONTHLY''"> '||
        '&'||'lt;SalaryMonthly currency="<xsl:value-of select="salary_currency"/>">'||
        '<xsl:value-of select="salary"/>&'||'lt;/SalaryMonthly>'||
      '</xsl:when>'||
      '<xsl:when test="salary_period=''HOURLY''"> '||
        '&'||'lt;RatePerHour currency="<xsl:value-of select="salary_currency"/>">'||
        '<xsl:value-of select="salary"/>&'||'lt;/RatePerHour> </xsl:when> <xsl:otherwise>'||
        '&'||'lt;SalaryAnnual currency="<xsl:value-of select="salary_currency"/>">'||
        '<xsl:value-of select="salary"/>&'||'lt;/SalaryAnnual> </xsl:otherwise></xsl:choose>'||
    '&'||'lt;/Pay> </xsl:if> '||
--
--            Do not generate the BenefitsDescription element and children if there is no
--            information to display
--
  '<xsl:if test="string-length(benefit_info)!=0 or count(comp_elements/comp_elements_row)!=0">'||
  '&'||'lt;BenefitsDescription>'||
  '&'||'lt;P><xsl:value-of select="benefit_info"/>&'||'lt;/P>'||
  '&'||'lt;UL>'||
    '<xsl:for-each select="comp_elements/comp_elements_row">'||
    '&'||'lt;LI><xsl:value-of select="var_comp"/>&'||'lt;/LI></xsl:for-each>'||
    '&'||'lt;/UL>'||
'&'||'lt;/BenefitsDescription></xsl:if>  '||
'&'||'lt;/CompensationDescription></xsl:if>'||
--
--            Do not generate the SummaryText element and children if there is no
--            information to display
--
'<xsl:if test="count(brief_description)!=0 or count(additional_details)!=0">'||
'&'||'lt;SummaryText>'||
'<xsl:if test="count(brief_description)!=0"> <xsl:value-of select="brief_description"/></xsl:if>'||
'<xsl:if test="count(additional_details)!=0"> <xsl:value-of select="additional_details"/></xsl:if>'||
'&'||'lt;/SummaryText>'||
'</xsl:if>'||
'&'||'lt;/JobPositionDescription>'||
'&'||'lt;JobPositionRequirements>'||
--
--           The competences can either be mandatory or preferred.
--
'<xsl:if test="count(competences/competences_row[mandatory=''Y''])!=0">'||
'&'||'lt;QualificationsRequired>&'||'lt;UL>'||
'<xsl:for-each select="competences/competences_row[mandatory=''Y'']">'||
'&'||'lt;LI>&'||'lt;Qualification><xsl:value-of select="name"/>&'||'lt;/Qualification>&'||'lt;/LI></xsl:for-each>'||
'&'||'lt;/UL>&'||'lt;/QualificationsRequired> </xsl:if>'||
--
-- Using !='Y' as opposed to ='N' in the next test to catch any nulls
--
'<xsl:if test="count(competences/competences_row[mandatory!=''Y''])!=0"> '||
'&'||'lt;QualificationsPreferred>&'||'lt;UL>'||
'<xsl:for-each select="competences/competences_row[mandatory!=''Y'']">'||
'&'||'lt;LI>&'||'lt;Qualification><xsl:value-of select="name"/>&'||'lt;/Qualification>&'||'lt;/LI></xsl:for-each>'||
'&'||'lt;/UL>&'||'lt;/QualificationsPreferred> </xsl:if>'||
'&'||'lt;TravelRequired>'||
'&'||'lt;PercentageOfTime><xsl:value-of select="travel_percentage"/>'||
'&'||'lt;/PercentageOfTime>'||
'&'||'lt;/TravelRequired>'||
'&'||'lt;SummaryText><xsl:value-of select="job_requirements"/>&'||'lt;/SummaryText>'||
'&'||'lt;/JobPositionRequirements>'||
'&'||'lt;/JobPositionInformation>'||
--
--      HowToApply element is mandatory so no need to check if data is available.
--
'&'||'lt;HowToApply>'||
'&'||'lt;ApplicationMethods>'||
'&'||'lt;ByWeb>'||
'&'||'lt;URL><xsl:value-of select="application_url"/>&'||'lt;/URL>'||
'&'||'lt;/ByWeb>'||
'&'||'lt;/ApplicationMethods>'||
'&'||'lt;SummaryText><xsl:value-of select="how_to_apply"/>&'||'lt;/SummaryText>'||
'&'||'lt;/HowToApply>'||
--
--      Only display NumberToFill XML element if number_of_openings info is available
--
'  <xsl:if test="string-length(number_of_openings)!=0">'||
'&'||'lt;NumberToFill><xsl:value-of select="number_of_openings"/>&'||'lt;/NumberToFill>'||
'  </xsl:if>'||
'&'||'lt;/JobPositionPosting>'||
']]&'||'gt;&'||'lt;/Payload>'||
'&'||'lt;/Packet>'||
'&'||'lt;/Envelope>'||
'</xsl:for-each>'||
'</xsl:template>'||
'</xsl:stylesheet>';
else
    l_stylesheet_url:=fnd_profile.value('APPS_FRAMEWORK_AGENT')||'/OA_HTML/'||p_stylesheet;
    tv_sheet:=  irc_xml_util.http_get_pieces(l_stylesheet_url,100);
    lv_stylesheet:='';
    for l_index in 1..tv_sheet.count loop
      lv_stylesheet:=lv_stylesheet||tv_sheet(l_index);
    end loop;
end if;


  ctx:= dbms_xmlquery.newContext(l_query);
  dbms_xmlquery.setBindValue(ctx,'1',p_recruitment_activity_id);
  dbms_xmlquery.setBindValue(ctx,'2',p_sender_id);
  dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
  dbms_xmlquery.setRowsetTag(ctx,'JobPositionPosting');
  clobdoc:=dbms_xmlquery.getXML(ctx);
  dbms_xmlquery.closeContext(ctx);
  --
  parser:=xmlparser.newparser;
-- parse the clob document
  xmlparser.parseCLOB(parser,clobdoc);
-- and put the parsed clob document in to an xml document
  xmldoc:=xmlparser.getDocument(parser);
  engine:=xslprocessor.newProcessor;
  dbms_lob.createTemporary(l_jpp_doc,false,dbms_lob.call);
-- create the stylesheet
  xmlparser.parseBuffer(parser,lv_stylesheet);
  stylesheetdoc:=xmlparser.getDocument(parser);
  stylesheet:=xslprocessor.newStylesheet(stylesheetdoc,null);
-- transform the queried xml document using the stylesheet
  xslprocessor.processXSL(engine,stylesheet,xmldoc,l_jpp_doc);
  l_jpp_doc:=dbms_xmlgen.convert(l_jpp_doc,1);
  xmlParser.freeParser(parser);
  xslprocessor.freeProcessor(engine);
  xmldom.freeDocument(xmldoc);
  xmldom.freeDocument(stylesheetdoc);
  p_jpp_doc:=l_jpp_doc;
--  p_jpp_doc:=clobdoc;
--  dbms_lob.write(p_jpp_doc,length(lv_stylesheet),1,lv_stylesheet);
  exception when others then
    xslprocessor.freeProcessor(engine);
    xmldom.freeDocument(xmldoc);
    xmldom.freeDocument(stylesheetdoc);
    raise;
end generateJPPint;
--
function generateJPP(p_recruitment_activity_id in number
                    ,p_sender_id in number
                    ,p_stylesheet varchar2 default null) return CLOB is
l_formatted_doc CLOB;
begin
    generateJPPint(p_recruitment_activity_id=>p_recruitment_activity_id
                  ,p_sender_id =>p_sender_id
                  ,p_stylesheet=>p_stylesheet
                  ,p_jpp_doc=>l_formatted_doc);

  return l_formatted_doc;

end generateJPP;
--
procedure show_posting(p in number
                      ,u in number
                      ,s in varchar2 default null) is
l_result CLOB;
begin
  l_result:=generateJPP(p,u,s);
  htp.p(dbms_lob.substr(l_result));
end show_posting;
--
function getXMLDataFromDB(p_recruitment_activity_id in number
                             ,p_sender_id in number) return clob  is
l_query varchar2(32767);
clobdoc CLOB;
ctx DBMS_XMLQUERY.ctxType;
begin
hr_utility.set_location('Entering getXMLDataFromDB',10);
l_query:=  'select hr_xml_packet_id_s.nextval packetId'
        ||' , ''CREATE'' action'
        ||' , hr_xml_transaction_id_s.nextval transactionid'
        ||' , translate(to_char(sysdate,''RRRR-MM-DD HH:MM:SS''),'' '',''T'') timestamp'
        ||' , rse.posting_url vendorURL'
        ||' , decode(rse.posting_username '
        ||'   ,''#USERID'',to_char(sndr_usr.user_id) '
        ||'   ,''#USERNAME'',sndr_usr.user_name '
        ||'   ,''#EMAIL'',nvl(sndr_per.email_address,sndr_usr.email_address)'
        ||'   , rse.posting_username) posting_username'
        ||' , decode(fnd_vault.get(''IRC_SITE'',rse.recruiting_site_id )'
        ||'   ,''#USERID'',to_char(sndr_usr.user_id) '
        ||'   ,''#USERNAME'',sndr_usr.user_name '
        ||'   ,''#EMAIL'',nvl(sndr_per.email_address,sndr_usr.email_address)'
        ||'   , fnd_vault.get(''IRC_SITE'',rse.recruiting_site_id) )posting_password'
        ||' , rse.stylesheet '
        ||' , sndr_per.last_name personlastname'
        ||' , sndr_per.first_name personfirstname'
        ||' , sndr_per.email_address emailaddress'
        ||' , sndr_usr.user_id userid'
        ||' , recr_pp.first_name recr_first_name'
        ||' , recr_pp.last_name recr_last_name'
        ||' , recr_pp.full_name recr_full_name'
        ||' , recr_pp.email_address recr_email_address'
        ||' , recr_phn.phone_number recr_phone_number'
        ||' , recr_phn_fax.phone_number recr_fax_number'
        ||' , recr_pp.person_id recr_person_id'
        ||' , vac.number_of_openings'
        ||' , vac.name vacancy_name'
        ||' , vac.business_group_id'
        ||' , vac.budget_measurement_type'
        ||' , vac.budget_measurement_value'
        ||' , to_char(vac.date_from,''RRRR-MM-DD'') vacancy_start_date'
        ||' , to_char(vac.date_to,''RRRR-MM-DD'') vacancy_end_date'
        ||' , (select name from hr_all_organization_units where organization_id=vac.business_group_id) organization_name'
        ||' , rtrim(nvl(fnd_profile.value(''IRC_FRAMEWORK_AGENT'')'
        ||' ,fnd_profile.value(''APPS_FRAMEWORK_AGENT''))||'
        ||' fnd_profile.value(''ICX_PREFIX''),''/'')||''/OA_HTML/OA.jsp?OAFunc=''||'
        ||' fnd_profile.value(''IRC_JOB_NOTIFICATION_URL'')||'
        ||' ''&p_svid=''||to_char(vac.vacancy_id)||'
        ||' ''&p_spid=''||to_char(ipc.posting_content_id)||';
        if(HR_MULTI_TENANCY_PKG.is_multi_tenant_system()) then
             l_query:=l_query ||' ''&OAMC=''||to_char(''R'')||' ;
        end if;
        l_query := l_query
        ||' ''&p_site_id=''||to_char(rse.recruiting_site_id) application_url'
        ||' , rtrim(fnd_profile.value(''APPS_FRAMEWORK_AGENT'')||'
        ||' fnd_profile.value(''ICX_PREFIX''),''/'')||''/OA_HTML/OA.jsp?OAFunc=''||'
        ||' fnd_profile.value(''IRC_JOB_NOTIFICATION_URL'')||'
        ||' ''&p_svid=''||to_char(vac.vacancy_id)||'
        ||' ''&p_spid=''||to_char(ipc.posting_content_id)||'
        ||' ''&p_site_id=''||to_char(rse.recruiting_site_id) int_application_url'
        ||' , vac.*'
        ||' , irc_isc.object_id'
        ||'     , hr_general.decode_lookup(''IRC_PROFESSIONAL_AREA'',irc_isc.professional_area) professional_area'
        ||'     , irc_isc.employee'
        ||'     , irc_isc.contractor'
        ||'     , irc_isc.employment_category'
        ||'     , irc_isc.min_salary'
        ||'     , irc_isc.max_salary'
        ||'     , nvl(irc_isc.max_salary,irc_isc.min_salary) salary'
        ||'     , irc_isc.salary_currency'
        ||'     , irc_isc.salary_period'
        ||'     , irc_isc.travel_percentage'
        ||'     , hr_general.decode_lookup(''IRC_TRAVEL_PERCENTAGE'',irc_isc.travel_percentage) travel'
        ||'     , decode(irc_isc.employment_category,''EITHER'',''Y'',''FULLTIME'',''Y'',''PARTTIME'',''N'',''Y'') full_time'
        ||'     , decode(irc_isc.employment_category,''EITHER'',''Y'',''PARTTIME'',''Y'',''FULLTIME'',''N'',''Y'') part_time'
        ||'     ,irc_isc.*'
        ||'     , ipc.display_recruiter_info'
        ||'     , ipctl.posting_content_id'
        ||'     , ipctl.name'
        ||'     , ipctl.org_name'
        ||'     , ipctl.org_description org_description'
        ||'     , nvl(ipctl.job_title,ipctl.name) job_title'
        ||'     , ipctl.brief_description brief_description'
        ||'      , ipctl.detailed_description detailed_description'
        ||'      , ipctl.job_requirements job_requirements'
        ||'      , ipctl.additional_details additional_details'
        ||'      , ipctl.how_to_apply how_to_apply'
        ||'      , ipctl.benefit_info benefit_info'
        ||'      , ipctl.*'
        ||'      , rec.recruitment_activity_id'
        ||'      , to_char(rec.date_start,''RRRR-MM-DD'') posting_start_date'
        ||'      , to_char(rec.date_end,''RRRR-MM-DD'') posting_end_date'
        ||'      , loc.address_line_1'
        ||'      , loc.address_line_2'
        ||'      , loc.address_line_3'
        ||'      , loc.town_or_city'
        ||'      , loc.country'
        ||'      , loc.postal_code'
        ||'      , loc.region_1'
        ||'      , loc.region_2'
        ||'      , loc.region_3'
        ||'      , loc.location_code'
          -- cursor to get the details of the competences/skills for the position
        ||'      , cursor (select irc_utilities_pkg.removeTags(pc.name) name '
        ||'                     , pce.mandatory '
        ||'                     , pc.competence_id '
        ||'                     , pce.competence_element_id '
        ||'                     , pc.*'
        ||'                     , pce.*'
        ||'                , prl1.step_value min_level_id '
        ||'                , prl2.step_value max_level_id '
        ||'                , prl1.name min_level '
        ||'                , prl2.name max_level'
        ||'             from per_competences_tl pc'
        ||'                , per_competence_elements pce'
        ||'                , per_rating_levels prl1'
        ||'                , per_rating_levels prl2'
        ||'             where  pc.language=ipctl.source_language'
        ||'               and pc.competence_id = pce.competence_id '
        ||'               and pce.type = ''REQUIREMENT'''
        ||'               and pce.object_name = ''VACANCY'''
        ||'               and pce.object_id = vac.vacancy_id'
        ||'               and prl1.rating_level_id(+) = pce.proficiency_level_id'
        ||'               and prl2.rating_level_id(+) = pce.high_proficiency_level_id'
        ||'               and vac.date_from '
        ||'                between nvl(pce.effective_date_from, vac.date_from)'
        ||'                   and nvl(pce.effective_date_to, vac.date_from)'
        ||'           ORDER BY pce.mandatory, pc.name DESC'
        ||'           ) competences'
-- cursor to get the variable comp element
        ||'   , cursor (select meaning var_comp from fnd_lookup_values_vl where lookup_type=''IRC_VARIABLE_COMP_ELEMENT'''
        ||'             and lookup_code in ( select variable_comp_lookup vce from irc_variable_comp_elements vce where  vac.vacancy_id = vce.vacancy_id)'
        ||'            ) comp_elements'
        ||' from  irc_posting_contents_tl ipctl'
        ||'    ,  irc_posting_contents ipc'
        ||'    ,  per_recruitment_activities rec'
        ||'    ,  per_recruitment_activity_for recf'
        ||'    ,  per_all_vacancies vac'
        ||'    ,  hr_locations_all_vl loc'
        ||'    ,  irc_search_criteria irc_isc'
        ||'    ,  irc_all_recruiting_sites rse'
        ||'    ,  fnd_user sndr_usr'
        ||'    ,  per_all_people_f   sndr_per'
        ||'    ,  per_all_people_f recr_pp'
        ||'    ,  per_phones recr_phn'
        ||'    ,  per_phones recr_phn_fax'
        ||' where rec.recruitment_activity_id=:1'
        ||'   and recf.vacancy_id = vac.vacancy_id'
        ||'   and not exists (select 1 from per_recruitment_activity_for recf2'
        ||'   where recf2.recruitment_activity_id =rec.recruitment_activity_id'
        ||'   and recf2.recruitment_activity_for_id>recf.recruitment_activity_for_id)'
        ||'   and rec.recruitment_activity_id = recf.recruitment_activity_id'
        ||'   and ipc.posting_content_id = rec.posting_content_id'
        ||'   and ipctl.posting_content_id = ipc.posting_content_id '
        ||'   and ipctl.source_language = userenv(''LANG'')'
        ||'   and rse.recruiting_site_id = rec.recruiting_site_id'
        ||'   and sndr_usr.user_id = :2'
        ||'   and sndr_usr.employee_id=sndr_per.person_id'
        ||'   and trunc(sysdate)'
        ||'       between sndr_per.effective_start_date and '
        ||'       sndr_per.effective_end_date'
        ||'   and vac.recruiter_id = recr_pp.person_id(+) '
        ||'   and vac.recruiter_id = recr_phn.parent_id(+) '
        ||'   and recr_phn.parent_table(+) = ''PER_ALL_PEOPLE_F'''
        ||'   and recr_phn.phone_type(+) = ''W1'''
        ||'   and vac.recruiter_id = recr_phn_fax.parent_id(+) '
        ||'   and recr_phn_fax.parent_table(+) = ''PER_ALL_PEOPLE_F'''
        ||'   and recr_phn_fax.phone_type(+) = ''WF'''
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_pp.effective_start_date,trunc(sysdate)) '
        ||'       and nvl(recr_pp.effective_end_date,trunc(sysdate))'
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_phn.date_from,trunc(sysdate))  '
        ||'       and nvl(recr_phn.date_to, trunc(sysdate)) '
        ||'   and trunc(sysdate)'
        ||'       between nvl(recr_phn_fax.date_from,trunc(sysdate))  '
        ||'       and nvl(recr_phn_fax.date_to, trunc(sysdate)) '
        ||'   and vac.location_id = loc.location_id (+)'
        ||'   and vac.vacancy_id = irc_isc.object_id (+)'
        ||'   and irc_isc.object_type(+) = ''VACANCY'''
        ||'   and rownum=1';
  ctx:= dbms_xmlquery.newContext(l_query);
  hr_utility.set_location('After  dbms_xmlquery.newContext',20);
  dbms_xmlquery.setBindValue(ctx,'1',p_recruitment_activity_id);
  hr_utility.set_location('p_recruitment_activity_id:'||p_recruitment_activity_id,30);
  dbms_xmlquery.setBindValue(ctx,'2',p_sender_id);
  hr_utility.set_location('p_sender_id:'||p_sender_id,40);
  dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
  dbms_xmlquery.setRowsetTag(ctx,'JobPositionPosting');
  dbms_xmlquery.setSqlToXmlNameEscaping(ctx,true);
  dbms_xmlquery.setEncodingTag(ctx,dbms_xmlquery.DB_ENCODING);
  hr_utility.set_location('After dbms_xmlquery.setEncodingTag',50);
  clobdoc:=dbms_xmlquery.getXML(ctx);
  hr_utility.set_location('After dbms_xmlquery.getXML',60);
  dbms_xmlquery.closeContext(ctx);
  hr_utility.set_location('Leaving getXMLDataFromDB',70);
  return clobdoc;

  exception when others then
    hr_utility.set_location('Exception occured',100);
    hr_utility.set_location('Exception: '||substrb(sqlerrm,1,160),110);
    hr_utility.set_location('Exception: '||sqlcode,120);
    raise;
end getXMLDataFromDB;

end;

/
