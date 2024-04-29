--------------------------------------------------------
--  DDL for Package Body CUG_SR_ATTRIBUTE_INTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_SR_ATTRIBUTE_INTF" AS
/* $Header: CUGATTPB.pls 120.3 2008/02/21 04:27:04 amganapa ship $ */

 PROCEDURE  CREATE_ATTR_TEMPLATE (errbuf        OUT     NOCOPY VARCHAR2,
                                  retcode       OUT     NOCOPY VARCHAR2,
                                  p_date        IN      VARCHAR2)
 IS
    /* Cursor to select attribute list for template */
        Cursor c_sr_attr (p_start_date date) is
            select   inctype.name                    sr_type
                   , srattr.incident_type_id         sr_type_id
                   , lkp.description                 sr_name
                   , srattr.sr_attribute_code        sr_code
                   , srattr.sr_attr_mandatory_flag   mandatory_flag
                   , srattr.sr_attribute_list_name   sr_attr_list_name
                   , srattr.sr_attr_default_value    default_value
                   , srattr.sr_attr_displayed_flag   displayed_flag
                   , srattr.start_date_active        start_date_active
                   , srattr.end_date_active          end_date_active
                   , srattr.last_update_date         last_update_date
                   , lkp.start_Date_active           lkup_start_Date
                   , lkp.end_date_active             lkup_end_Date
                   ,srattr.sr_type_attr_seq_num
            from     cug_sr_type_attr_maps_vl srattr
                   , cs_incident_types_vl     inctype
                   , fnd_lookup_values        lkp
            where  srattr.incident_type_id = inctype.incident_type_id
              and  srattr.sr_attribute_code = lkp.lookup_code
              and  lkp.lookup_type = 'CUG_SR_TYPE_ATTRIBUTES'
              and  lkp.language = userenv('lang')
              and  (trunc(srattr.last_update_date) >= trunc(p_start_date)
                  or trunc(lkp.last_update_date) >= trunc(p_start_date))
--              and  trunc(srattr.last_update_date) >= trunc(p_start_date)
            order by sr_type , srattr.sr_type_attr_seq_num;

    /* Cursor to select attribute ListName */
        Cursor C_attr_listName (P_attr_code varchar2, p_start_date date) is
            select  lookup_code
                  , meaning
            from    fnd_lookup_values
            where   lookup_code = p_attr_code
              and   trunc(last_update_date) >= trunc(p_start_date);

    /* Cursor to check Existence of template in CS schema) */
        cursor c_template_exists (p_template_name varchar2) IS
	      select   lnk.template_id      template_id
           from     cs_tp_template_links lnk
                  , cs_tp_templates_vl   tmpl
           where  tmpl.template_id = lnk.template_id
             and  tmpl.name 		= p_template_name;

    /* Cursor to check Existence of template attributes */
        cursor c_template_attr_exists (p_templ_id number, p_attr_name varchar2) IS
           SELECT   tmpq.template_id  template_id
                  , tmpq.question_id  question_id
			      , quest.lookup_id   lookup_id
                  , quest.name        qname
	      		  , quest.text        qtext
	       		  , quest.description qdesc
           FROM     cs_tp_template_questions tmpq
                  , cs_tp_questions_vl       quest
           WHERE    tmpq.question_id = quest.question_id
             AND    tmpq.template_id = p_templ_id
             AND    quest.name       = p_attr_name;

    /* Cursor to query records from FND_LOOKUP table for List_Name*/
        cursor c_template_choice_lookup (p_lookup_type varchar2) IS
            SELECT   lookup_code         lookup_code
                   , meaning             meaning
                   , description         description
                   , start_date_active   start_date_active
                   , end_date_active     end_date_active
                   , last_update_date    last_update_date
            FROM   fnd_lookup_values
            WHERE  lookup_type = p_lookup_type
              AND  trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                                      and trunc(nvl(end_date_active,sysdate))
              AND  language = userenv('LANG');

    /* Cursor to query record from CS_TP_CHOICES_VL for deleting records from choices */
        cursor c_tp_choice (p_lookup_id number) IS
            select choice_id, value, default_choice_flag
            from   cs_tp_choices_vl
            where  lookup_id = p_lookup_id;

    /* Cursor to query record from CS_TP_FREETEXTS for deleting records from freetext */
        cursor c_tp_freetext (p_lookup_id number) IS
            select freetext_id, lookup_id
            from   cs_tp_freetexts
            where  lookup_id = p_lookup_id;

    /* Defining local variables*/
        l_sr_attr 		       c_sr_attr%ROWTYPE;
        l_attr_listName		   c_attr_listName%ROWTYPE;
        l_tmpl_exists		   c_template_exists%ROWTYPE;
        l_tmpl_attr_exists	   c_template_attr_exists%ROWTYPE;
        l_tmpl_choice_lookup   c_template_choice_lookup%ROWTYPE;
        l_tp_choice            c_tp_choice%ROWTYPE;
        l_tp_freetext          c_tp_freetext%ROWTYPE;

        l_attr_update_flag	   boolean;
        l_update_flag		   boolean ;
        l_tmpl_id              number := 0;
        l_tmpl_quest_id        number := 0;
        l_tmpl_quest_lookup_id number := 0;
        l_tmpl_quest_choice_id number := 0;
        l_tmpl_quest_freetext_id number := 0;
        l_rowid                varchar2(30);
        l_date                 date;

        /* Defining Record type's for insert/update*/

        l_template_rec                  cs_tp_templates_pvt.template;
        l_template_link_list            cs_tp_templates_pvt.template_link_list;
        l_template_question_list        cs_tp_questions_pvt.question;
        l_template_question_choice      cs_tp_choices_pvt.choice;
        --l_template_quest_choice_list    cs_tp_choices_pvt.choice_list;
        l_template_question_freetext    cs_tp_choices_pvt.freetext;


    BEGIN

    /* Opening the main cursor to fetch new/update sr attribute records to be processed */

        fnd_file.put_line(fnd_file.log,'Start of SR Attribute Interface logic');
        fnd_file.put_line(fnd_file.log,'Parameter Start Date :' || p_date);

        select to_date(p_date, 'YYYY/MM/DD HH24:MI:SS') INTO l_date from dual;

        fnd_file.put_line(fnd_file.log,'Parameter Start Date :' || to_char(l_date,'DD-MON-YYYY'));

        --FOR l_sr_attr in c_sr_attr LOOP
        OPEN c_sr_attr (l_date);
        FETCH c_sr_attr INTO l_sr_attr;

        WHILE (c_sr_attr%FOUND) loop

fnd_file.put_line(fnd_file.log, '***----------------------- Start of New Record processing ---------------------***');
            fnd_file.put_line(fnd_file.log,'l_sr_attr loop, SR Type :' || l_sr_attr.sr_type);

            l_update_flag := false;
            l_attr_update_flag := false;

            l_template_rec.mTemplateName           := l_sr_attr.sr_type;
            l_template_rec.mstartdate              := l_sr_attr.start_date_active;
            l_template_rec.menddate                := l_sr_attr.end_date_active;
            l_template_rec.mdefaultflag            := 'F';
            l_template_rec.mlast_updated_date        := l_sr_attr.last_update_date;
            l_template_rec.mtemplateid             := NULL;
            l_template_link_list(1).mJTF_OBJECT_CODE  := 'IBU_TP_SR_TYPE';
            l_template_link_list(1).mOther_id         := l_sr_attr.sr_type_id;
            l_template_link_list(1).mLast_Updated_Date := l_sr_attr.last_update_date;
    --        l_template_link_list.lookup_code       := NULL;
    --        l_template_link_list.lookup_type       := NULL;
    --        l_template_rec.short_code              := NULL;   -- maps to cs_tp_templates_b.attribute1
    --        l_template_link_list.mlinkid           := NULL;
    --        l_template_link_list.mlinkname         := NULL;
    --        l_template_link_list.mlinkdesc         := NULL;

        -- open the cursor of template_exists to verify if template already created
            open c_template_exists (l_sr_attr.sr_type);
            fetch c_template_exists into l_tmpl_exists;

            /* Check if the cursor fetched any records */
            if c_template_exists%NOTFOUND then
                -- Calling the create template API to create new template record
                fnd_file.put_line(fnd_file.log,'Template does not exists for SR Type : ' || l_sr_attr.sr_type);
                fnd_file.put_line(fnd_file.log,'Calling Create Template API, SR Type : ' || l_sr_attr.sr_type);
                CS_TP_TEMPLATES_PVT.Add_Template
                   (
                     p_api_version_number => l_api_version,
                     p_init_msg_list      => l_init_msg_list_true,
                     p_commit             => l_init_commit_true,
                     p_one_template       => l_template_rec,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => x_return_status,
                     x_template_id        => l_tmpl_id
                   );

                -- Calling the create template link API to create new template link record
                fnd_file.put_line(fnd_file.log,'Template does not exists for SR Type : ' || l_sr_attr.sr_type);
                fnd_file.put_line(fnd_file.log,'Calling Create Template Link API, SR Type : ' || l_sr_attr.sr_type);
                CS_TP_TEMPLATES_PVT.update_template_links
                   (
                     p_api_version_number => l_api_version,
                     p_init_msg_list      => l_init_msg_list_true,
                     p_commit             => l_init_commit_true,
                     p_template_id        => l_tmpl_id,
                     p_jtf_object_code    => l_template_link_list(1).mjtf_object_code,
                     p_template_links     => l_template_link_list,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_return_status      => x_return_status
                   );
            else
                fnd_file.put_line(fnd_file.log,'Template already defined for SR Type : '|| l_sr_attr.sr_type);
                l_tmpl_id := l_tmpl_exists.template_id;
            end if;
            close c_template_exists;

         fnd_file.put_line(fnd_file.log,'Attribute Code: ' || l_sr_attr.sr_name);

 -- Check for if attribute StartDateActive and EndDateActive has value
-- Added the trunc for bug fix 2435523

-- Start of changes for bug fix 3547950, by aneemuch 02-Apr-2004

/*            if ( (trunc(nvl(l_sr_attr.start_date_active, sysdate)) <= trunc(sysdate))
                 and (trunc(nvl(l_sr_attr.end_date_active, sysdate)) >= trunc(sysdate))
                 and l_sr_attr.displayed_flag = 'Y') then
*/

            if (( (trunc(nvl(l_sr_attr.start_date_active, sysdate)) <= trunc(sysdate)
                 and trunc(nvl(l_sr_attr.end_date_active, sysdate)) >= trunc(sysdate))
                 and (trunc(nvl(l_sr_attr.lkup_start_date, sysdate)) <= trunc(sysdate)
                    and trunc(nvl(l_sr_attr.lkup_end_date, sysdate)) >= trunc(sysdate)))
                 and l_sr_attr.displayed_flag = 'Y') then

-- End of changes for bug fix 3547950, by aneemuch 02-Apr-2004

                fnd_file.put_line(fnd_file.log,'Attribute is valid for start and end date, SR Type: '
                   || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name
                   || ' And Display_Flag is set to YES ');

                l_template_question_list.mquestionname := l_sr_attr.sr_name;

                if (l_sr_attr.sr_attr_list_name is NULL) then
                    l_template_question_list.manswertype := 'FREETEXT';
                else
                    l_template_question_list.manswertype := 'CHOICE';
                end if;

                if (l_sr_attr.mandatory_flag = 'Y') then
                    l_template_question_list.mmandatoryflag := 'T';
                else
                    l_template_question_list.mmandatoryflag := 'F';
                end if;

                l_template_question_list.mscoringflag  := FND_API.G_FALSE;
                l_template_question_list.mlast_updated_date := l_sr_attr.last_update_date;

                /* Check if attribute questions Exists */
                open c_template_attr_exists (l_tmpl_id, l_sr_attr.sr_name);
                fetch c_template_attr_exists into l_tmpl_attr_exists;

                /* Check if the cursor fetched any records */
                fnd_file.put_line(fnd_file.log,'Check if attribute already defined in CS table, SR Type: '
                                  || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);

                if c_template_attr_exists%NOTFOUND then
                    fnd_file.put_line(fnd_file.log,'attribute not defined in CS table, SR Type: '
                                      || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);

                    -- Calling the create template question API to create new template question record
                    l_attr_update_flag := false;
                    l_template_question_list.mquestionid := NULL;
                    l_template_question_list.mlookupid := NULL;

                    fnd_file.put_line(fnd_file.log,'Calling the Add_question API,SR Type: '
                                      || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);
                    CS_TP_QUESTIONS_PVT.Add_Question
                       (
                        p_api_version_number     => l_api_version,
                        p_init_msg_list          => l_init_msg_list_true,
                        p_commit                 => l_init_commit_true,
                        p_one_question           => l_template_question_list,
                        p_template_id            => l_tmpl_id,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data,
                        x_return_status          => x_return_status,
                        x_question_id            => l_tmpl_quest_id
                       );
                else
                    -- Calling the update template question API to update template question record
                fnd_file.put_line(fnd_file.log,'Attribute defined in CS table, SR Type: '
                                  || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);
                    l_attr_update_flag := true;
                    l_tmpl_quest_id    := l_tmpl_attr_exists.question_id;
                    l_template_question_list.mquestionid := l_tmpl_attr_exists.question_id;
                    l_template_question_list.mlookupid := l_tmpl_attr_exists.lookup_id;
                    l_template_question_list.mlast_updated_date := to_char(l_sr_attr.last_update_date, 'MM/DD/YYYY/SSSSS');

                fnd_file.put_line(fnd_file.log,'Calling the Update_question API, SR Type: '
                          || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);

                    CS_TP_QUESTIONS_PVT.Update_Question
                       (
                        p_api_version_number     => l_api_version,
                        p_init_msg_list          => l_init_msg_list_true,
                        p_commit                 => l_init_commit_true,
                        p_one_question           => l_template_question_list,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data,
                        x_return_status          => x_return_status
                       );

                fnd_file.put_line(fnd_file.log,'Calling CS_TP_LOOKUPS_PKG.UPDATE_ROW API, SR Type: '
                                  || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);

                    CS_TP_LOOKUPS_PKG.UPDATE_ROW
                       (
                        X_ROWID             => l_rowid,
                        X_LOOKUP_ID         => l_template_question_list.mlookupid,
                        X_LOOKUP_TYPE       => l_template_question_list.manswertype,
                        X_DEFAULT_VALUE     => l_sr_attr.default_value, --Bug 6705077
            			X_CREATION_DATE     => sysdate,
			            X_CREATED_BY	    => FND_GLOBAL.user_id,
                        X_LAST_UPDATE_DATE  => sysdate,
                        X_LAST_UPDATED_BY   => FND_GLOBAL.user_id,
                        X_LAST_UPDATE_LOGIN => fnd_global.login_id,
                        X_START_DATE_ACTIVE => NULL,
                        X_END_DATE_ACTIVE   => NULL,
            			X_ATTRIBUTE_CATEGORY => NULL,
			            X_ATTRIBUTE1	=> NULL,
            			X_ATTRIBUTE2	=> NULL,
			            X_ATTRIBUTE3	=> NULL,
            			X_ATTRIBUTE4	=> NULL,
            			X_ATTRIBUTE5	=> NULL,
            			X_ATTRIBUTE6	=> NULL,
            			X_ATTRIBUTE7	=> NULL,
            			X_ATTRIBUTE8	=> NULL,
            			X_ATTRIBUTE9	=> NULL,
            			X_ATTRIBUTE10	=> NULL,
			            X_ATTRIBUTE11	=> NULL,
            			X_ATTRIBUTE12	=> NULL,
            			X_ATTRIBUTE13	=> NULL,
            			X_ATTRIBUTE14	=> NULL,
            			X_ATTRIBUTE15	=> NULL
                       );

                  --IF FND_API.To_Boolean( l_init_commit_true ) THEN
                  --   COMMIT WORK;
                  --END IF;

                end if;
                close c_template_attr_exists;

                /* get the template question lookupid */
                select   l.lookup_id into l_tmpl_quest_lookup_id
                from     cs_tp_questions_vl q
                       , cs_tp_lookups l
                       , cs_tp_template_questions tq
                where  q.lookup_id    = l.lookup_id
                  and  tq.question_id = q.question_id
                  and  tq.template_id = l_tmpl_id
                  and  q.question_id  = l_tmpl_quest_id;

      fnd_file.put_line(fnd_file.log,'Check if attribute is freetext or LOV, SR Type: '
              || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name ||l_sr_attr.sr_attr_list_name);

                /* Check for if the Attribute has LOV for answer */
                if  l_sr_attr.sr_attr_list_name is NULL then
                    fnd_file.put_line(fnd_file.log, 'attribute is a FREETEXT');
                    -- Means, attribute is a freetext attribute

                    /* Check if the attribute was previously defined as LOV */
                    if l_attr_update_flag = TRUE then
                        -- only to do this if the attribute is in update mode
                        -- Call the delete program to delete all the records from the cs_tp_choices_tl

            fnd_file.put_line(fnd_file.log,'Calling the delete Choice API, attribute is freetext and attribute is in updatemode, SR Type: '
                              || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);
                        open c_tp_choice (l_tmpl_quest_lookup_id);
                        fetch c_tp_choice into l_tp_choice;
                        while (c_tp_choice%FOUND) loop
                            CS_TP_CHOICES_PVT.DELETE_CHOICE
                               (
                                p_api_version_number     => l_api_version,
                                p_init_msg_list          => l_init_msg_list_true,
                                p_commit                 => l_init_commit_true,
                                p_choice_id              => l_tp_choice.choice_id,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                x_return_status          => x_return_status
                               );
                            fetch c_tp_choice into l_tp_choice;
                        end loop;
                        close c_tp_choice;
                    end if;

                    -- Call the create FreeText API to create a new record
                    l_template_question_freetext.mfreetextsize := 5;
                    l_template_question_freetext.mfreetextdefaulttext := NULL;
                    l_template_question_freetext.mlookupid :=l_tmpl_quest_lookup_id;
                    l_template_question_freetext.mlast_updated_date:= l_sr_attr.last_update_date;

                fnd_file.put_line(fnd_file.log,'Calling the Add_Freetext API, SR Type: '
                                  || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);
                    CS_TP_CHOICES_PVT.ADD_FREETEXT
                       (
                        p_api_version_number     => l_api_version,
                        p_init_msg_list          => l_init_msg_list_true,
                        p_commit                 => l_init_commit_true,
                        p_one_freetext           => l_template_question_freetext,
                        x_msg_count              => x_msg_count,
                        x_msg_data               => x_msg_data,
                        x_return_status          => x_return_status,
                        x_freetext_id            => l_tmpl_quest_freetext_id
                       );
                else
                    -- Means, attribute is defined as a LOV column
                    fnd_file.put_line(fnd_file.log, 'attribute is a LOV');
                    if l_attr_update_flag = TRUE then
                        -- only to do this if the attribute is in update mode
                        -- Call the delete program to delete all the records from the cs_tp_choices_tl
     fnd_file.put_line(fnd_file.log,'Calling the delete Choice API, attribute is in update mode, SR Type: '
                       || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);

                        open c_tp_choice (l_tmpl_quest_lookup_id);
                        fetch c_tp_choice into l_tp_choice;
                        while (c_tp_choice%FOUND) loop
                            CS_TP_CHOICES_PVT.DELETE_CHOICE
                               (
                                p_api_version_number     => l_api_version,
                                p_init_msg_list          => l_init_msg_list_true,
                                p_commit                 => l_init_commit_true,
                                p_choice_id              => l_tp_choice.choice_id,
                                x_msg_count              => x_msg_count,
                                x_msg_data               => x_msg_data,
                                x_return_status          => x_return_status
                               );
                            fetch c_tp_choice into l_tp_choice;
                        end loop;
                        close c_tp_choice;

                  -- Also, call delete FreeText API to delete record from freetext table if previously defined as freetext
            fnd_file.put_line(fnd_file.log,'Calling the delete Free_Text API incase attribute was defined as freetext before, attribute is in update mode, SR Type: '
 || l_sr_attr.sr_type || ' Attribute : '|| l_sr_attr.sr_name);
                        open c_tp_freetext (l_tmpl_quest_lookup_id);
                        fetch c_tp_freetext into l_tp_freetext;
                        while (c_tp_freetext%FOUND) loop
                            CS_TP_FREETEXTS_PKG.DELETE_ROW(l_tp_freetext.freetext_id);
                            fetch c_tp_freetext into l_tp_freetext;
                        end loop;
                        close c_tp_freetext;

                    end if;

                    -- Call the create question API to create new record in choices table

       		    OPEN c_template_choice_lookup (l_sr_attr.sr_attr_list_name);
                    FETCH c_template_choice_lookup INTO l_tmpl_choice_lookup;
                    WHILE (c_template_choice_lookup%FOUND) LOOP
                        l_template_question_choice.mchoiceid          := NULL;
                        l_template_question_choice.mchoicename        := l_tmpl_choice_lookup.description;
                        l_template_question_choice.mlookupid         := l_tmpl_quest_lookup_id;
                        l_template_question_choice.mscore            := 0;
                        l_template_question_choice.mlast_updated_date  := l_tmpl_choice_lookup.last_update_date;

   fnd_file.put_line(fnd_file.log,'Calling the Add_Choice API, SR Type: ' || l_sr_attr.sr_type ||
    ' Attribute : '|| l_sr_attr.sr_name || ' Choice : ' ||l_tmpl_choice_lookup.meaning ||'- DESC:'||l_tmpl_choice_lookup.description);
                        CS_TP_CHOICES_PVT.ADD_CHOICE
                           (
                            p_api_version_number     => l_api_version,
                            p_init_msg_list          => l_init_msg_list_true,
                            p_commit                 => l_init_commit_true,
                            p_one_choice             => l_template_question_choice,
                            x_msg_count              => x_msg_count,
                            x_msg_data               => x_msg_data,
                            x_return_status          => x_return_status,
                            x_choice_id              => l_tmpl_quest_choice_id
                           );

                        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

                        FETCH c_template_choice_lookup INTO l_tmpl_choice_lookup;

                    end loop;
                    close c_template_choice_lookup;
            end if;
        ELSE   -- Else condition of StartDateActive and EndDateActive
        -- Delete records from the CS table for the attribute that has been
        -- End dated or has been marked for future date or the display flag is set to NO
        -- Current API's of iSupport does not support end_date update

-- Start of changed for bug fix 3547950, by aneemuch

/*            fnd_file.put_line(fnd_file.log,'SR Type: ' || l_sr_attr.sr_type ||
                              ' StartDate : ' || l_sr_attr.start_date_active ||
                              ' EndDateActive : ' || l_sr_attr.end_date_active ||
                              ' DisplayedFlag : ' || l_sr_attr.displayed_flag);
*/

            fnd_file.put_line(fnd_file.log,'SR Type: ' || l_sr_attr.sr_type ||
                              ' StartDate : ' || l_sr_attr.start_date_active ||
                              ' EndDateActive : ' || l_sr_attr.end_date_active ||
                              ' DisplayedFlag : ' || l_sr_attr.displayed_flag ||
                              ' LkupStartDate: '|| l_sr_attr.lkup_start_Date||
                              ' LkupEndDate: ' || l_sr_attr.lkup_end_date);

-- End of changed for bug fix 3547950, by aneemuch

            open c_template_attr_exists (l_tmpl_id, l_sr_attr.sr_name);
            fetch c_template_attr_exists into l_tmpl_attr_exists;

            /* Check if the cursor fetched any records */
            if c_template_attr_exists%FOUND then
            fnd_file.put_line(fnd_file.log,'Calling Delete Question API for attribute is enddated, SR Type: ' || l_sr_attr.sr_type);
                cs_tp_questions_pvt.Delete_Question
                (
                    p_api_version_number     => l_api_version,
                    p_init_msg_list          => l_init_msg_list_true,
                    p_commit                 => l_init_commit_true,
                    p_Question_ID  	         => l_tmpl_attr_exists.question_id,
    	           p_Template_ID            => l_tmpl_attr_exists.template_id,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data,
                    x_return_status          => x_return_status
                );
            end if;
            close c_template_attr_exists;
        END IF;
        COMMIT WORK;

fnd_file.put_line(fnd_file.log, '***-------------------- End of Current Record processing ---------------------***');
        FETCH c_sr_attr INTO l_sr_attr;

    end loop; --for;
    retcode := 0;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR then

	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
        retcode :=2;

      WHEN OTHERS THEN
        Errbuf := fnd_message.get||'     '||SQLERRM;
        Retcode := 2;
        fnd_file.put_line(fnd_file.log,'others '||sqlerrm||to_char(sqlcode));

END  CREATE_ATTR_TEMPLATE;



PROCEDURE Update_Attr_ListName ( errbuf        OUT     NOCOPY VARCHAR2,
                                 retcode       OUT     NOCOPY VARCHAR2,
                                 p_lookup_type IN      VARCHAR2)
IS

/* Cursor to query record from cug_sr_type_attr_maps_v table */
    Cursor c_cug_sr_attr_ListName (p_lookup_type varchar2) is
        select   cs.name                      tmpl_name
               , attr.sr_attribute_code       attr_code
               , lkps.lookup_type             list_name
               , lkps1.description            sr_name
               , attr.start_date_Active       start_date_active
               , attr.end_date_active         end_date_active
        from     cug_sr_type_attr_maps_vl     attr
               , fnd_lookup_types             lkps
               , fnd_lookups                  lkps1
               , cs_incident_types_vl         cs
        where    lkps.lookup_type = attr.sr_attribute_list_name
          and    attr.sr_attribute_list_name = p_lookup_type
          and    lkps1.lookup_code = attr.sr_attribute_code
          and    cs.incident_type_id = attr.incident_type_id
          and    (trunc(nvl(attr.end_date_active,sysdate)) >= trunc(sysdate));
          --and    (attr.end_date_active is NULL or attr.end_date_active >= sysdate);

/* Cursor to query record from fnd_lookup table for a ListName */
    Cursor c_fnd_lookup (p_lookup_type varchar2) is
        select   lookup_code        lookup_code
               , meaning            meaning
               , description        description
               , lookup_type        lookup_type
               , start_date_active  start_date_active
               , end_date_active    end_date_active
	       , last_update_date   last_update_date
        from    fnd_lookup_values
        where   trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                                   and trunc(nvl(end_date_active,sysdate))
        and     lookup_type = p_lookup_type
        and     language = userenv('LANG');

/* Cursor to query record from questions table */
    Cursor c_tp_question (p_attr_name varchar2, p_tmpl_name varchar2) is
        select   tmpl.name          tmpl_name
               , qvl.name           name
               , qvl.text           text
               , qvl.lookup_id      lookup_id
               , ch.lookup_type     choice_id
        from     cs_tp_questions_vl qvl
               , cs_tp_lookups    ch
               , cs_tp_template_questions tmpl_qa
	       , cs_tp_templates_vl       tmpl
        where    qvl.lookup_id   = ch.lookup_id
          and    ch.lookup_type  = 'CHOICE'
          and    tmpl_qa.question_id = qvl.question_id
	  and    tmpl_qa.template_id = tmpl.template_id
          and    qvl.name            = p_attr_name
	  and    tmpl.name           = p_tmpl_name;

/* Cursor to query records from choices  */
    Cursor c_tp_choice (p_lookup_id number) is
        select   choice_id
               , lookup_id
               , value
        from     cs_tp_choices_vl
        where    lookup_id = p_lookup_id;

/* Define recordtypes for the above cursor */
    l_cug_sr_attr_ListName c_cug_sr_attr_ListName%ROWTYPE;
    l_fnd_lookup           c_fnd_lookup%ROWTYPE;
    l_tp_question          c_tp_question%ROWTYPE;
    l_tp_choice            c_tp_choice%ROWTYPE;

    l_lookup_id            number   := 0;
    l_choice_id            number   := 0;

    /* Define recordtype for Questions to be created */
    l_templ_question_list cs_tp_choices_pvt.choice;

BEGIN

    fnd_file.put_line(fnd_file.log,'Start of program');
    OPEN c_cug_sr_attr_ListName (P_lookup_type);
    fetch c_cug_sr_attr_ListName into l_cug_sr_attr_ListName;
    WHILE (c_cug_sr_attr_ListName%FOUND) LOOP

        fnd_file.put_line(fnd_file.log,'Attribute Name : ' || l_cug_sr_attr_ListName.sr_name ||
                              ' LOV Name : ' || l_cug_sr_attr_ListName.list_name);

        /* open cursor for choices table and call delete api to delete existing record */
        OPEN c_tp_question (l_cug_sr_attr_ListName.sr_name, l_cug_sr_attr_ListName.tmpl_name);
        FETCH c_tp_question into l_tp_question;
        while (c_tp_question%FOUND) loop
            l_lookup_id := l_tp_question.lookup_id;

            -- call delete choice api to delete records first
            OPEN c_tp_choice (l_lookup_id);
            Fetch c_tp_choice into l_tp_choice;

            fnd_file.put_line(fnd_file.log,'Delete Choice before re-creating, '
                  || 'SR Type : ' ||  l_cug_sr_attr_ListName.tmpl_name
                  || 'Attribute Name : '
                  || l_cug_sr_attr_ListName.sr_name || ' LOV Name : '
                  || l_cug_sr_attr_ListName.list_name);

            while (c_tp_choice%FOUND) loop
--                fnd_file.put_line(fnd_file.log,'Delete Choice before re-creating, '
--                            ||'SR Type : ' || l_cug_sr_attr_ListName.tmpl_name
--                            ||' Attribute Name : ' || l_cug_sr_attr_ListName.sr_name || ' LOV Name : '
--                            || l_cug_sr_attr_ListName.list_name
--                            || ' ChoiceID : ' || l_tp_choice.value);

                CS_TP_CHOICES_PVT.DELETE_CHOICE
                (
                 p_api_version_number     => l_api_version,
                 p_init_msg_list          => l_init_msg_list_true,
                 p_commit                 => l_init_commit_true,
                 p_choice_id              => l_tp_choice.choice_id,
                 x_msg_count              => x_msg_count,
                 x_msg_data               => x_msg_data,
                 x_return_status          => x_return_status
                );

                fetch c_tp_choice into l_tp_choice;
            end loop;
            close c_tp_choice;

        /* open the fnd_lookup cursor to re-create choices */
            OPEN c_fnd_lookup (p_lookup_type);
            FETCH c_fnd_lookup into l_fnd_lookup;

             fnd_file.put_line(fnd_file.log,'Re-creating choices, SR Type : ' ||
             l_cug_sr_attr_ListName.tmpl_name || ' Attribute Name : ' ||
             l_cug_sr_attr_ListName.sr_name || ' LOV Name : ' || l_cug_sr_attr_ListName.list_name);

            while (c_fnd_lookup%FOUND) loop
                l_templ_question_list.mchoiceid          := NULL;
                l_templ_question_list.mchoicename        := l_fnd_lookup.description;
                l_templ_question_list.mlookupid         := l_lookup_id;
                l_templ_question_list.mscore            := 0;
                l_templ_question_list.mlast_updated_date  := l_fnd_lookup.last_update_date;
                l_templ_question_list.mdefaultchoiceflag := FND_API.G_FALSE;

--                fnd_file.put_line(fnd_file.log,'Re-creating choices, Attribute Name : ' ||
--                l_cug_sr_attr_ListName.sr_name || ' LOV Name : ' || l_cug_sr_attr_ListName.list_name
--                || ' ChoiceName : ' || l_fnd_lookup.description);

                CS_TP_CHOICES_PVT.ADD_CHOICE
                   (
                    p_api_version_number     => l_api_version,
                    p_init_msg_list          => l_init_msg_list_true,
                    p_commit                 => l_init_commit_true,
                    p_one_choice             => l_templ_question_list,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data,
                    x_return_status          => x_return_status,
                    x_choice_id              => l_choice_id
                   );

                FETCH c_fnd_lookup into l_fnd_lookup;
            end loop;
            close c_fnd_lookup;

            FETCH c_tp_question into l_tp_question;
        end loop;
        close c_tp_question;

        COMMIT WORK;

        FETCH c_cug_sr_attr_ListName into l_cug_sr_attr_ListName;
    end loop;
    close c_cug_sr_attr_ListName;

EXCEPTION
      WHEN OTHERS THEN
        Errbuf := fnd_message.get||'     '||SQLERRM;
        Retcode := 2;
        fnd_file.put_line(fnd_file.log,'others '||sqlerrm||to_char(sqlcode));

END Update_Attr_ListName;

END CUG_SR_ATTRIBUTE_INTF;

/
