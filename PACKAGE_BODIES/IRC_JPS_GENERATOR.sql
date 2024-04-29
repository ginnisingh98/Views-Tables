--------------------------------------------------------
--  DDL for Package Body IRC_JPS_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_JPS_GENERATOR" as
/* $Header: irjpsgen.pkb 120.11.12010000.3 2009/05/21 13:58:01 amikukum ship $ */

procedure generateJPSint(p_person_id in number
                     ,p_stylesheet varchar2 default null
                     ,p_raw_doc out nocopy clob
                     ,p_formatted_doc out nocopy clob) is
l_query varchar2(32767);
l_formatted_doc CLOB;
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

hr_utility.set_location('Entering: generateJPSinit',10);
l_query:=        'select per.*'
        ||' ,per.full_name personname'
        ||' ,per.last_name personlastname'
        ||' ,decode(per.sex, ''M'',''1'',''F'',''2'',''9'') gender'
        ||' ,translate(to_char(per.date_of_birth,''RRRR-MM-DD HH:MM:SS''),'' '',''T'') dateofbirth'
        --
        -- This cursor retrieves all the Recruiting addresses associated
        -- with the person
        --
        ||' ,cursor (select address_line1 addressline1'
        ||'                ,address_line2 addressline2'
        ||'                ,address_line3 addressline3'
        ||'                ,region_1 region1'
        ||'                ,region_2 region2'
        ||'                ,region_3 region3'
        ||'                ,postal_code postalcode'
        ||'                ,town_or_city townorcity'
        ||'                ,country country'
        ||'                ,add_information13'
        ||'                ,add_information14'
        ||'                ,add_information15'
        ||'                ,add_information16'
        ||'                ,add_information17'
        ||'                ,add_information18'
        ||'                ,add_information19'
        ||'                ,add_information20'
        ||'          from per_addresses'
        ||'         where address_type = ''REC'''
        ||'           and person_id=per.person_id) as address'
        --
        -- This cursor retrieves the telephone numbers that can be passed
        -- The decode statement is used to get the correct order by :
        -- the translate removes H and W, and changes 1,2 and 3 to Vs
        -- as they are irrelevant to the numbering
        --
        ||'  ,cursor ( select phn.*'
        ||'                , substr(phone_type,1,1)  phonelabel'
        ||'                , decode (translate(phone_type,''123HW'',''VVV'')'
        ||'                         ,''V'', ''1'''
        ||'                         ,''F'', ''2'''
        ||'                         ,''P'', ''3'''
        ||'                         ,''1'') phonetype'
        ||'             from per_phones phn'
        ||'            where parent_id=per.person_id'
        ||'              and substr(phone_type, 1,1) in (''H'',''W'',''P'',''M'')) as phone'
        ||' ,usr.email_address emailaddress'
        ||' ,cursor(select ppe.*'
        ||'        ,ppj.job_name job_name,ppj.*'
        ||'        ,ppe.employer_name employername'
        ||'        ,ppe.employer_address employeraddress'
        ||'        ,ppe.description descriptionText'
        ||'        ,to_char(ppe.start_date,''RRRR-MM-DD'') attendedstartdate'
        ||'        ,to_char(ppe.end_date,''RRRR-MM-DD'') attendedenddate'
        ||'         from per_previous_employers ppe'
        ||'         ,per_previous_jobs ppj'
        ||'          where ppe.previous_employer_id = ppj.previous_employer_id'
        ||'            and ppe.person_id=per.person_id) as emphistory'
        --
        -- This cursor retrieves the qualifications held in per_qualifications.
        -- 'attendanceid' is used in the stylesheet to determine the section
        -- of the generated XML document to place the data.
        --
        ||' ,cursor(select qua.title title,qua.*'
        ||'               ,esa.establishment establishment'
        ||'               ,esa.address address'
        ||'               ,esa.*'
        ||'               ,qtytl.name type'
        ||'               ,decode(qty.category '
        ||'                      ,''SKILL'', ''skill'''
        ||'                      ,''EXPERIENCE'', ''experience'''
        ||'                      ,''EDUCATION'', ''education'''
        ||'                      ,''LICENSE'', ''license'''
        ||'                      ,''CERTIFICATION'', ''certification'''
        ||'                      ,''EQUIPMENT'', ''equipment'''
        ||'                      ,''other'') categoryCode'
        ||'               ,to_char(esa.attended_start_date,''RRRR-MM-DD'') attendedstartdate'
        ||'               ,to_char(esa.attended_end_date,''RRRR-MM-DD'') attendedenddate'
        ||'          from per_qualifications_vl qua'
        ||'              ,per_qualification_types qty'
        ||'              ,per_qualification_types_tl qtytl'
        ||'              ,per_establishment_attendances esa'
        ||'         where qua.qualification_type_id = qty.qualification_type_id'
        ||'         and qua.qualification_type_id = qtytl.qualification_type_id'
        ||'         and ppttl.language = qtytl.language'
        ||'           and qua.attendance_id = esa.attendance_id'
        ||'           and qua.person_id = per.person_id'
        ||'           and esa.person_id=per.person_id) as education'

        ||' ,cursor(select qua.title title,qua.*'
        ||'               ,qty.name type'
        ||'               ,decode(qty.category '
        ||'                      ,''SKILL'', ''skill'''
        ||'                      ,''EXPERIENCE'', ''experience'''
        ||'                      ,''EDUCATION'', ''education'''
        ||'                      ,''LICENSE'', ''license'''
        ||'                      ,''CERTIFICATION'', ''certification'''
        ||'                      ,''EQUIPMENT'', ''equipment'''
        ||'                      ,''other'') categoryCode'
        ||'          from per_qualifications_vl qua'
        ||'              ,per_qualification_types qty'
        ||'              ,per_qualification_types_tl qtytl'
        ||'         where qua.qualification_type_id = qty.qualification_type_id'
        ||'         and qua.qualification_type_id = qtytl.qualification_type_id'
        ||'         and ppttl.language = qtytl.language'
        ||'           and qua.attendance_id is null'
        ||'           and qua.person_id=per.person_id) as non_edu_quals'
        --
        -- This cursor retrieves the skills that are held the competences
        -- tables.  Only skills that have an associated rating_level are
        -- required
        --
        ||' ,cursor(select /*+ INDEX (rtl PER_RATING_LEVELS_PK)'
        ||' INDEX(cmp PER_COMPETENCES_PK) INDEX(rsc PER_RATING_SCALES_PK)*/ '
        ||' cel.*,cmpt.name name'
        ||'              , decode(round((rtl.step_value/decode(nvl(nvl(rsc.max_scale_step, cmp.max_level)'
        ||'               ,rtl.step_value),0,1,nvl(nvl(rsc.max_scale_step, cmp.max_level)'
        ||'               ,rtl.step_value)))*5),0,1'
        ||'               , round((rtl.step_value/decode(nvl(nvl(rsc.max_scale_step, cmp.max_level)'
        ||'               ,rtl.step_value),0,1,nvl(nvl(rsc.max_scale_step, cmp.max_level)'
        ||'               ,rtl.step_value)))*5)) lvl'
        ||'          from per_competence_elements cel'
        ||'             , per_competences cmp'
        ||'             , per_competences_tl cmpt'
        ||'             , per_rating_levels rtl'
        ||'             , per_rating_scales rsc'
        ||'          where cel.competence_id = cmp.competence_id'
        ||'          and cel.competence_id = cmpt.competence_id'
        ||'          and ppttl.language= cmpt.language'
        ||'            and cel.proficiency_level_id = rtl.rating_level_id'
        ||'            and rtl.rating_scale_id = rsc.rating_scale_id(+)'
        ||'            and cel.type = ''PERSONAL'''
        ||'            and cel.person_id = per.person_id) as skills'
        ||' ,cursor(select cel.*,cmp.name name'
        ||'          from per_competence_elements cel'
        ||'             , per_competences_tl cmp'
        ||'          where cel.competence_id = cmp.competence_id'
        ||'            and cmp.language=ppttl.language'
        ||'            and cel.proficiency_level_id is null'
        ||'            and cel.type = ''PERSONAL'''
        ||'            and cel.person_id = per.person_id) as skills_no_level'
        ||' , cursor(select isc.* '
        ||'          ,cursor(select * from irc_location_criteria_values ilcv'
        ||'                  where ilcv.search_criteria_id=isc.search_criteria_id) as locations'
        ||'          ,cursor(select * from irc_prof_area_criteria_values ipacv'
        ||'                  where ipacv.search_criteria_id=isc.search_criteria_id) as professional_areas'
        ||'           from irc_search_criteria isc'
        ||'          where  isc.object_id=per.person_id'
        ||'          and isc.object_type=''WPREF'') as work_preferences'
        ||' from per_all_people_f per '
        ||'     ,fnd_user usr '
        ||'     ,per_person_types_tl ppttl '
        ||' where per.person_id =  :1'
        ||'   and usr.employee_id(+)=per.person_id'
        ||'   and trunc(sysdate) between nvl(usr.start_date(+),trunc(sysdate))'
        ||'   and nvl(usr.end_date(+),trunc(sysdate))'
        ||'   and trunc(sysdate) between per.effective_start_date'
        ||'   and per.effective_end_date'
        ||'   and per.person_type_id=ppttl.person_type_id'
        ||'   and ppttl.language=userenv(''LANG'')'
        ||'   and rownum=1';

  hr_utility.set_location('Formed the query to retrieve data',11);

  if (p_stylesheet is null) then

  hr_utility.set_location('Stylesheet is null',12);

lv_stylesheet:='<?xml version="1.0" ?>'||
'<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">'||
'<xsl:output  method="xml" indent="yes" doctype-system="JobPositionSeeker-1_1.dtd"/>'||
'<xsl:template match="jobpositionseeker">'||
'<xsl:for-each select="row">
';

lv_stylesheet:=lv_stylesheet||'<JobPositionSeeker>
'||'<JobPositionSeekerId idOwner="oracle.com"><xsl:value-of select="person_id"/></JobPositionSeekerId>
'||'<PersonalData>
'||'<PersonName>
'||'<FormattedName><xsl:value-of select="personname"/></FormattedName>
'||'<GivenName><xsl:value-of select="first_name"/></GivenName>
'||'<PreferredGivenName><xsl:value-of select="known_as"/></PreferredGivenName>
'||'<MiddleName><xsl:value-of select="middle_names"/></MiddleName>
'||'<FamilyName prefix="{pre_name_adjunct}"><xsl:value-of select="personlastname"/></FamilyName>
'||'<Affix type="formOfAddress"><xsl:value-of select="title"/></Affix>
'||'<Affix type="qualification"><xsl:value-of select="honors"/></Affix>
'||'</PersonName>
'||'<!--Dont display address XML if there are no addresses -->
'||'<xsl:if test="count(address/address_row/country)!=0">
'||'<xsl:for-each select="address/address_row">'||'<PostalAddress>
'||'<CountryCode><xsl:value-of select="country"/></CountryCode>
'||'<PostalCode><xsl:value-of select="postalcode"/></PostalCode>
'||'<Region><xsl:value-of select="region1"/></Region>
'||'<Region><xsl:value-of select="region2"/></Region>
'||'<Region><xsl:value-of select="region3"/></Region>
'||'<Municipality><xsl:value-of select="townorcity"/></Municipality>
'||'<DeliveryAddress>
'||'<AddressLine><xsl:value-of select="addressline1"/></AddressLine>
'||'<AddressLine><xsl:value-of select="addressline2"/></AddressLine>
'||'<AddressLine><xsl:value-of select="addressline3"/></AddressLine>
'||'</DeliveryAddress>
'||'</PostalAddress>
'||'</xsl:for-each>
'||'</xsl:if>
'||'<xsl:for-each select="phone/phone_row">
'||'<xsl:sort select="phonetype"/><!-- This is 1(for Voice), 2(for Fax), 3(for pager)-->
'||'<xsl:choose>
'||'<xsl:when test="phonetype=''1''"><!-- Phone No is  a Voice number -->'||'<VoiceNumber label="{phonelabel}">
'||'<TelNumber><xsl:value-of select="phone_number"/></TelNumber>
'||'</VoiceNumber>
'||'</xsl:when>
'||'<xsl:when test="phonetype=''2''"><!-- Phone No. is a Fax number -->'||'<FaxNumber label="{phonelabel}">
'||'<TelNumber><xsl:value-of select="phone_number"/></TelNumber>
'||'</FaxNumber>
'||'</xsl:when>
'||'<xsl:when test="phonetype=''3''"><!-- Phone No. is a Pager number -->'||'<PagerNumber label="{phonelabel}">
'||'<TelNumber><xsl:value-of select="phone_number"/></TelNumber>
'||'</PagerNumber>
'||'</xsl:when>
'||'</xsl:choose>
'||'</xsl:for-each>'||'<E-mail><xsl:value-of select="emailaddress"/></E-mail>
'||'<DemographicDetail>
'||'<GovernmentId countryCode="{identifiercountry}"><xsl:value-of select="national_identifer"/></GovernmentId>
'||'<DateOfBirth>
'||'<Date><xsl:value-of select="dateofbirth"/></Date>
'||'</DateOfBirth>
'||'<Sex type="{gender}"/>
'||'<Ethnicity><xsl:value-of select="declaredethnicity"/></Ethnicity>
'||'<Language><xsl:value-of select="correspondence_language"/></Language>
'||'</DemographicDetail>
'||'</PersonalData>
'||'<!-- Only write the profile section if there are rows in education with a title
'||'       but not an attendance_id -->
'||'<xsl:if test="count(non_edu_quals/non_edu_quals_row/title) !=0">'||'<Profile>
<xsl:for-each select="non_edu_quals/non_edu_quals_row">
'||'<Qualification type="{categorycode}" description="{type}">
'||'<xsl:value-of select="title"/>
'||'</Qualification></xsl:for-each>
'||'</Profile></xsl:if>
'||'<Resume>
'||'<!-- The element StructuredResume should not be displayed if there isnt going
'||' to be any data in it.  Therefore a few checks need to be made.-->
'||'<xsl:if test="count(education/education_row/attendance_id)!=0
'||' or count(skills/skills_row/name)!=0
'||' or count(education/education_row/attendance_id)!=0
'||' or count(emphistory/emphistory_row/employername)!=0 ">'||'<StructuredResume>
'||'<xsl:if test="count(emphistory/emphistory_row/employername)!=0">'||'<EmploymentHistory>
'||'<xsl:for-each select="emphistory/emphistory_row">'||'<Position>
'||'<EmployerName><xsl:value-of select="employername"/></EmployerName>
'||'<JobPositionLocation>
'||'<PostalAddress>
'||'<CountryCode><xsl:value-of select="employer_country"/></CountryCode>
'||'<DeliveryAddress>
'||'<AddressLine><xsl:value-of select="employeraddress"/></AddressLine>
'||'</DeliveryAddress>
'||'</PostalAddress>
'||'</JobPositionLocation>
'||'<PositionTitle><xsl:value-of select="job_name"/></PositionTitle>
'||'<Industry><NAICS><xsl:value-of select="employer_type"/></NAICS></Industry>
'||'<EffectiveDate>
'||'<StartDate>
'||'<Date><xsl:value-of select="attendedstartdate"/></Date>
'||'</StartDate>
'||'<EndDate>
'||'<Date><xsl:value-of select="attendedenddate"/></Date>
'||'</EndDate>
'||'</EffectiveDate>
'||'<SummaryText><xsl:value-of select="descriptionText"/></SummaryText>
'||'</Position>
'||'</xsl:for-each>'||'</EmploymentHistory>
'||'</xsl:if>
'||'<!-- Only add a SchoolOrInstitution element if the person has qualifications
'||'         gained in a named SchoolOrInstitution.-->
'||'<xsl:if test="count(education/education_row/attendance_id)!=0"> '||'<EducationQualifs><xsl:for-each select="education/education_row">
'||'<SchoolOrInstitution>
'||'<SchoolName><xsl:value-of select="establishment"/></SchoolName>
'||'<LocationSummary>
'||'<Region><xsl:value-of select="address"/></Region>
'||'</LocationSummary>
'||'<EduDegree degreeType="{type}"><xsl:value-of select="title"/></EduDegree>
'||'<GPA><xsl:value-of select="grade_attained"/></GPA>
'||'<EffectiveDate>
'||'<StartDate>
'||'<Date><xsl:value-of select="attendedstartdate"/></Date>
'||'</StartDate>
'||'<EndDate>
'||'<Date><xsl:value-of select="attendedenddate"/></Date>
'||'</EndDate>
'||'</EffectiveDate>
'||'</SchoolOrInstitution>
'||'</xsl:for-each> '||'</EducationQualifs></xsl:if>
'||'<!-- Only display the skills if there is any to display
'||'           The check ensures that one mandatory column is present -->
'||'<xsl:if test="count(skills/skills_row/name)!=0">
'||'<SkillQualifs><xsl:for-each select="skills/skills_row">
'||'<Skill level= "{lvl}">
'||'<SkillName><xsl:value-of select="name"/></SkillName>
'||'</Skill></xsl:for-each>
'||'</SkillQualifs>
'||'</xsl:if>
'||'</StructuredResume>
'||'</xsl:if>'||'<TextOrNonXMLResume>
'||'<ResumeLink>
'||'<Link><xsl:value-of select="textornonxmlresume/textornonxmlresume_row/sit_job"/>
'||'</Link>
'||'</ResumeLink>
'||'</TextOrNonXMLResume>
'||'</Resume>
</JobPositionSeeker></xsl:for-each>
</xsl:template>
</xsl:stylesheet>';
hr_utility.set_location('Created the stylesheet',13);

  else
  hr_utility.set_location('Stylesheet is not null',14);

    begin
    hr_utility.set_location('Getting stylesheet from URL',15);

    l_stylesheet_url:=rtrim(fnd_profile.value('APPS_FRAMEWORK_AGENT'),'/')||'/OA_HTML/'||userenv('LANG')||'/'||p_stylesheet;
    tv_sheet:=  irc_xml_util.http_get_pieces(l_stylesheet_url,100);
    if instr(lower(tv_sheet(1)),'<?xml')<>1 then
      l_stylesheet_url:=rtrim(fnd_profile.value('APPS_FRAMEWORK_AGENT'),'/')||'/OA_HTML/'||p_stylesheet;
      tv_sheet:=  irc_xml_util.http_get_pieces(l_stylesheet_url,100);
    end if;
    hr_utility.set_location('Got the stylesheet from the URL',16);

    exception when others then
      hr_utility.set_location('Exception occured while getting stylesheet',17);
      hr_utility.set_location('Exception: '||substrb(sqlerrm,1,160),18);
      hr_utility.set_location('Exception: '||sqlcode,19);
      l_stylesheet_url:=rtrim(fnd_profile.value('APPS_FRAMEWORK_AGENT'),'/')||'/OA_HTML/'||p_stylesheet;
      tv_sheet:=  irc_xml_util.http_get_pieces(l_stylesheet_url,100);
    end;
    lv_stylesheet:='';
    for l_index in 1..tv_sheet.count loop
      lv_stylesheet:=lv_stylesheet||tv_sheet(l_index);
    end loop;
    hr_utility.set_location('Created the Stylesheet',20);
  end if;
  hr_utility.set_location('Executing the query',21);
  ctx:= dbms_xmlquery.newContext(l_query);
  dbms_xmlquery.setBindValue(ctx,'1',p_person_id);
  dbms_xmlquery.setTagCase(ctx,dbms_xmlquery.LOWER_CASE);
  dbms_xmlquery.setRowsetTag(ctx,'jobpositionseeker');
  clobdoc:=dbms_xmlquery.getXML(ctx);
  hr_utility.set_location('Retrieved the XML data',22);
  dbms_xmlquery.closeContext(ctx);
  dbms_lob.createTemporary(l_formatted_doc,false,dbms_lob.call);
  hr_utility.set_location('Entering Parsing section',23);
  parser:=xmlparser.newparser;

  hr_utility.set_location('Setting encoding',231);
  if(fnd_profile.value('ICX_CLIENT_IANA_ENCODING') <> '') then
  clobdoc := replace(clobdoc, '?>', ' encoding = '''||fnd_profile.value('ICX_CLIENT_IANA_ENCODING')||'''?>');
  end if;
  hr_utility.set_location('Exiting after setting encoding',233);

  xmlparser.parseCLOB(parser,clobdoc);
  xmldoc:=xmlparser.getDocument(parser);
  engine:=xslprocessor.newProcessor;
  xmlparser.parseBuffer(parser,lv_stylesheet);
  stylesheetdoc:=xmlparser.getDocument(parser);
  stylesheet:=xslprocessor.newStylesheet(stylesheetdoc,null);
  hr_utility.set_location('Parsing the stylesheet',24);
  xslprocessor.processXSL(engine,stylesheet,xmldoc,l_formatted_doc);
  hr_utility.set_location('Parsing Sucess. Freeing parser',25);
  xslprocessor.freeStylesheet(stylesheet);
  xmldom.freeDocument(stylesheetdoc);
  xmlParser.freeParser(parser);
  xslprocessor.freeProcessor(engine);
  xmldom.freeDocument(xmldoc);
  p_raw_doc:=clobdoc;

  if(p_stylesheet is null and substr(l_formatted_doc,0,5)<> '<?xml') then
l_formatted_doc :='<?xml version = ''1.0'' encoding = ''UTF-8''?>
<!DOCTYPE JobPositionSeeker SYSTEM "JobPositionSeeker-1_1.dtd">' || l_formatted_doc;
end if;

  p_formatted_doc:=l_formatted_doc;
--  p_formatted_doc:=clobdoc;
 hr_utility.set_location('Generation successful',26);
  exception when others then
    hr_utility.set_location('Exception occured',27);
    hr_utility.set_location('Exception: '||substrb(sqlerrm,1,160),28);
    hr_utility.set_location('Exception: '||sqlcode,29);
    xmlParser.freeParser(parser);
    xslprocessor.freeProcessor(engine);
    xslprocessor.freeStylesheet(stylesheet);
    xmldom.freeDocument(xmldoc);
    xmldom.freeDocument(stylesheetdoc);
    raise;
end generateJPSint;
--
function generateJPS(p_person_id in number
                    ,p_stylesheet varchar2 default null) return CLOB is
l_dummy_doc CLOB;
l_formatted_doc CLOB;
l_stylesheet varchar2(240);
begin
  hr_utility.set_location('Entering generateJPS',10);
  if (p_stylesheet is not null) then
    hr_utility.set_location('Stylesheet not null',11);
    l_stylesheet:=p_stylesheet||'.xsl';
    hr_utility.set_location('Calling generateJPSint with stylesheet',12);
    generateJPSint(p_person_id=>p_person_id
                  ,p_stylesheet=>l_stylesheet
                  ,p_raw_doc=>l_dummy_doc
                  ,p_formatted_doc=>l_formatted_doc);
  else
    hr_utility.set_location('Calling generateJPSint without stylesheet',12);
    generateJPSint(p_person_id=>p_person_id
                  ,p_raw_doc=>l_dummy_doc
                  ,p_formatted_doc=>l_formatted_doc);
  end if;
  return l_formatted_doc;
end generateJPS;
--
procedure show_resume(p number,s varchar2) is
--
l_result CLOB;
begin
  hr_utility.set_location('Entering show_resume',10);
  l_result:=generateJPS(p,s);
  htp.p(dbms_lob.substr(l_result));
exception
when others then
  hr_utility.set_location('Exception occured',20);
  hr_utility.set_location('Exception: '||substrb(sqlerrm,1,160),30);
  hr_utility.set_location('Exception: '||sqlcode,40);
  htp.p(dbms_utility.format_error_stack);
end show_resume;
--
procedure save_candidate_resume(p_person_id in number
                               ,p_stylesheet in varchar2
                               ,p_assignment_id in number default null
                               ,p_overwrite boolean default true) is
--
cursor get_first_resume is
select document_id
from irc_documents
where person_id=p_person_id
and type='AUTO_RESUME'
and nvl(assignment_id,-1)=nvl(p_assignment_id,-1)
order by creation_date asc;
--
cursor get_doc_name is
select substr(replace(initcap(full_name),' '),1,120)
from per_all_people_f
where person_id=p_person_id
and sysdate between effective_start_date and effective_end_date;
l_binary_doc blob;
l_character_doc clob;
l_parsed_xml clob;
l_document_id number;
l_overwriting boolean :=false;
l_ovn number;
text_data varchar2(32767);
l_amount number;
l_position number;
l_block_size number:=10000;
l_file_name varchar(125);
l_description varchar2(240);
l_stylesheet varchar2(240);
--
cursor get_meaning(p_type varchar2) is
select meaning
from hr_lookups
where lookup_type=p_type
and lookup_code=p_stylesheet;
l_meaning varchar2(240);
l_proc varchar2(72) := 'irc_JPS_generator.save_candidate_resume';
l_error_added boolean;
Begin
--
hr_multi_message.enable_message_list;
--
hr_utility.set_location('Entering save_candidate_resume',10);
open get_doc_name;
fetch get_doc_name into l_file_name;
close get_doc_name;
if l_file_name is null then
  l_file_name:=to_char(sysdate,'YYYY-MM-DD');
end if;
l_file_name:=l_file_name||'.htm';
--
open get_meaning('IRC_RESUME_STYLE');
fetch get_meaning into l_meaning;
close get_meaning;
fnd_message.set_name('PER','IRC_SAVE_RES_DESC');
fnd_message.set_token('STYLE',l_meaning);
l_description:=substrb(fnd_message.get,1,240);
fnd_message.clear;
--
hr_utility.set_location('Getting stylesheet',11);
l_stylesheet:=p_stylesheet||'.xsl';
generateJPSint(p_person_id=>p_person_id
              ,p_stylesheet=>l_stylesheet
              ,p_raw_doc =>l_parsed_xml
              ,p_formatted_doc=>l_character_doc);
dbms_lob.createTemporary(l_binary_doc,false,dbms_lob.call);
l_position:=1;
loop
  l_amount:=l_block_size;
  dbms_lob.read(l_character_doc,l_amount,l_position,text_data);
  dbms_lob.write(l_binary_doc,l_amount,l_position,utl_raw.cast_to_raw(text_data));
  if(l_amount<l_block_size) then
    exit;
  end if;
  l_position:=l_position+l_amount;
end loop;

  if (p_overwrite) then
    open get_first_resume;
    fetch get_first_resume into l_document_id;
    if get_first_resume%found then
      l_overwriting:=true;
      update irc_documents
      set binary_doc=l_binary_doc
      ,character_doc=empty_clob()
      ,parsed_xml=l_parsed_xml
      ,mime_type='text/html'
      ,file_format='TEXT'
      ,file_name=l_file_name
      ,description=l_description
      where document_id=l_document_id;
    end if;
    close get_first_resume;
  end if;
--
  if not l_overwriting then
    irc_document_api.create_document
      (p_validate => false
      ,p_effective_date=>sysdate
      ,p_type=>'AUTO_RESUME'
      ,p_person_id=>p_person_id
      ,p_assignment_id=>p_assignment_id
      ,p_mime_type=>'text/html'
      ,p_file_name=>l_file_name
      ,p_description=>l_description
      ,p_document_id=>l_document_id
      ,p_object_version_number=>l_ovn);
    --
    update irc_documents
    set binary_doc=l_binary_doc
    ,parsed_xml=l_parsed_xml
    where document_id=l_document_id;
  end if;
  irc_document_api.process_document(l_document_id);
--
hr_utility.set_location('Saved resume',12);
exception
  when others then
    hr_utility.set_location('Exception occured',20);
    hr_utility.set_location('Exception: '||substrb(sqlerrm,1,160),30);
    hr_utility.set_location('Exception: '||sqlcode,40);
    l_error_added := hr_multi_message.unexpected_error_add(l_proc);
    raise;
end save_candidate_resume;
end;

/
