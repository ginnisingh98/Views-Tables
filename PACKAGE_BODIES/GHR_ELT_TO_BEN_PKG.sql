--------------------------------------------------------
--  DDL for Package Body GHR_ELT_TO_BEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_ELT_TO_BEN_PKG" AS
/* $Header: ghbencnv.pkb 120.6.12010000.15 2009/12/10 10:36:04 utokachi ship $ */



g_proc_name VARCHAR2(100);

TYPE lt_person_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_person_ids lt_person_ids;

-- ============================================================================
--                        << Procedure: execute_conv_mt >>
--  Description:
--  This procedure is called from concurrent program. This procedure will
--  determine the batch size and call sub programs.
-- ============================================================================
PROCEDURE EXECUTE_CONV_MT(p_errbuf OUT NOCOPY VARCHAR2
                         ,p_retcode OUT NOCOPY NUMBER
					     ,p_batch_size IN NUMBER
					     ,p_thread_size IN NUMBER)       IS

    -- Cursor to fetch distinct person records.
    CURSOR c_per_records IS
    SELECT distinct a.person_id person_id
    FROM   per_all_people_f a,hr_organization_information hoi
    WHERE  a.business_group_id = hoi.organization_id
    AND    hoi.org_information_context = 'GHR_US_ORG_INFORMATION';

    -- Cursor to find total number of distinct person records
    CURSOR c_tot_per_records IS
    SELECT COUNT(distinct a.person_id) person_count
    FROM   per_all_people_f a,hr_organization_information hoi
    WHERE  a.business_group_id = hoi.organization_id
    AND    hoi.org_information_context = 'GHR_US_ORG_INFORMATION';

    CURSOR c_completion_status(c_session_id NUMBER) IS
    SELECT max(completion_status) max_status
    FROM   GHR_MTS_TEMP
    WHERE  session_id = c_session_id;

    -- Declaration of Local variables
    l_batch_size        NUMBER;
    l_thread_size       NUMBER;
    l_batch_no          NUMBER;
    l_batch_counter     NUMBER;
    l_session_id        NUMBER;
    l_parent_request_id NUMBER;
    l_completion_status NUMBER;
    l_request_id        NUMBER;
    l_count             NUMBER;
    l_status            BOOLEAN;
    l_log_text	        VARCHAR2(2000);
    l_result            VARCHAR2(200);
    rphase              VARCHAR2(80);
    rstatus             VARCHAR2(80);
    dphase              VARCHAR2(30);
    dstatus             VARCHAR2(30);
    message             VARCHAR2(240);
    call_status         BOOLEAN;
    l_update_name       pay_upgrade_definitions.short_name%type;

BEGIN
	-- Initialization of variables.
	l_batch_counter     := 0;
	l_batch_no          := 1;
	l_session_id        := USERENV('SESSIONID');
	l_parent_request_id := fnd_profile.VALUE('CONC_REQUEST_ID');
	l_status            := TRUE;
	g_person_ids.DELETE;
	g_proc_name         := 'GHR_BEN_EIT_CREATION_'|| l_parent_request_id;
    l_update_name       := 'GHR_ELT_BEN_CONV';

    --
    -- Need to delete the PAY_UPGRADE_STATUS record if the user requested
    -- Manual submission of Conc. Request
    DELETE FROM pay_upgrade_status
    WHERE       upgrade_definition_id =  (SELECT upgrade_definition_id
                                          FROM   pay_upgrade_definitions
                                          WHERE  short_name = l_update_name);

	-- Thread size should be minimum of 10.
	IF p_thread_size IS NULL OR p_thread_size < 10 THEN
		l_thread_size := 10;
	ELSIF p_thread_size > 35 THEN
		l_thread_size := 35;
	ELSE
		l_thread_size := p_thread_size;
	END IF;

	-- Batch size should be minimum of 1000.
	IF p_batch_size IS NULL OR p_batch_size < 1000 THEN
		l_batch_size := 1000;
	ELSE
		l_batch_size := p_batch_size;
	END IF;

	-- Find out Total future action records
    FOR l_tot_per_rec IN c_tot_per_records LOOP
        l_count := l_tot_per_rec.person_count;
    END LOOP;

	-- Revise the batch size if the total future action record is more than
	-- the product of thread size and batch size.
	IF l_count > (l_thread_size * l_batch_size) THEN
		l_batch_size := CEIL(l_count/l_thread_size);
	END IF;

	-- Loop through the person records and insert them into the appropriate batch.
    -- If the batch size exceeds the limit, then insert the following records into the next batch.
    FOR l_c_per_records IN c_per_records
    LOOP
        l_result := NULL;
        IF NVL(l_result,'NOT EXISTS') = 'NOT EXISTS' THEN
            IF l_batch_counter >= l_batch_size  THEN
                l_batch_no := l_batch_no + 1;
                l_batch_counter := 0;
            END IF;
            -- Insert values into the table
            INSERT INTO GHR_MTS_TEMP(session_id, batch_no, pa_request_id, action_type)
                              VALUES(l_session_id,l_batch_no,l_c_per_records.person_id, NULL);
            l_batch_counter := l_batch_counter + 1;
            END IF;
    END LOOP;

	COMMIT;

	-- Call child concurrent programs for each and every thread
	l_log_text := 'Total number of employees: ' || l_count || ' : Number of Batches  ' || l_batch_no || ' : Batch size ' || l_batch_size;
	ghr_wgi_pkg.create_ghr_errorlog(
						p_program_name	=> g_proc_name,
						p_log_text		=> l_log_text,
						p_message_name	=> 'Number of Batches',
						p_log_date		=> sysdate
					);
	COMMIT;

	-- Commented for testing
	FOR l_thread IN 1..l_batch_no LOOP
		-- Concurrent program
		l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                   application => 'GHR',
				   program => 'GHSUBBENCONV',
				   sub_request => FALSE,
				   argument1=> l_session_id, -- Session ID
				   argument2=> l_thread, -- Batch no
				   argument3=> l_parent_request_id -- Parent request id
                 );
		g_person_ids(l_thread) := l_request_id;
--		fnd_conc_global.set_req_globals(conc_status => 'PAUSED');
	END LOOP;

	COMMIT;

	IF g_person_ids.COUNT > 0 THEN
		-- Wait for the child concurrent programs to get finished
		FOR l_thread_count IN 1..l_batch_no LOOP
			l_status := TRUE;
			hr_utility.set_location('batch ' || l_thread_count,1000);
			hr_utility.set_location('request id  ' || g_person_ids(l_thread_count),1000);
			WHILE l_status = TRUE LOOP
				call_status := FND_CONCURRENT.GET_REQUEST_STATUS(g_person_ids(l_thread_count),'','',rphase,rstatus,dphase,dstatus, message);
				hr_utility.set_location('dphase  ' || dphase,1000);
				IF dphase = 'COMPLETE' THEN
					l_status := FALSE;
				ELSE
					dbms_lock.sleep(5);
				END IF;
			END LOOP;
		END LOOP;
	END IF;

	FOR l_cur_compl_status IN c_completion_status(l_session_id) LOOP
		l_completion_status := l_cur_compl_status.max_status;
	END LOOP;

	--hr_utility.trace_off;
	-- Assigning Return codes
	IF l_completion_status = 2 THEN
		p_retcode := 2;
		p_errbuf  := 'There were errors in some person records. Please verify Federal Process Log for details';
	ELSIF l_completion_status = 1 THEN
		p_retcode := 1;
		p_errbuf  := 'There were errors in some person records. Please verify Federal Process Log for details' ;
	ELSE
		p_retcode := 0;
        --
        -- insert the history record in table pay_upgrade_status.
        --
        hr_update_utility.setUpdateProcessing(p_update_name => l_update_name);
        hr_update_utility.setUpdateComplete(p_update_name => l_update_name);
        --
    END IF;

	-- Delete the temporary table data.
	DELETE FROM GHR_MTS_TEMP
		WHERE session_id = l_session_id;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		p_retcode := 1;
		p_errbuf := SQLERRM;
    	DELETE FROM GHR_MTS_TEMP
		WHERE session_id = l_session_id;
	    COMMIT;
END EXECUTE_CONV_MT;

-- *******************************
-- procedure execute_conversion
-- *******************************
Procedure execute_conversion (p_errbuf             OUT NOCOPY VARCHAR2
			                 ,p_retcode            OUT NOCOPY NUMBER
                             ,p_session_id        IN NUMBER
                             ,p_batch_no          IN NUMBER
              			     ,p_parent_request_id IN NUMBER) IS

    -- Variable Declaration
    l_current_bg_id       NUMBER(15);
    l_current_person_id   NUMBER(15);
    l_benefits_eit_rec    ghr_api.per_benefit_info_type;
    l_pa_history_rec      ghr_pa_history%rowtype;
    l_new_effective_date  DATE;
    l_old_effective_date  DATE;
    l_cnt                 NUMBER;
    l_log_text            ghr_process_log.log_text%TYPE;
    l_program_name        ghr_process_log.program_name%TYPE;
    l_req                 VARCHAR2 (25);
    l_errbuf              VARCHAR2(2000);
    l_retcode             NUMBER;

    l_per_err_cnt         NUMBER(15);
    l_ssn                 per_all_people_f.national_identifier%TYPE;
    l_full_name           per_all_people_f.full_name%TYPE;
    l_dummy               VARCHAR2(1);
    l_sid                 NUMBER;
    -- ****** MAIN Program CURSORS *********
    -- Cursor to verify whether Person benefits EIT is created or not
    CURSOR c_eit_exists IS
    SELECT 'x'
    FROM   per_people_info_types
    WHERE  information_type = 'GHR_US_PER_BENEFIT_INFO';

    -- Cursor to pick person records of Federal Persons
    CURSOR c_batch_persons(c_session_id IN NUMBER,
				           c_batch_no IN NUMBER) IS
    SELECT pa_request_id person_id, batch_no
    FROM   GHR_MTS_TEMP
    WHERE  session_id = c_session_id
    AND    batch_no = c_batch_no;

    CURSOR c_sessionid is
    SELECT userenv('sessionid') sesid
    FROM   dual;

    -- Cursor to pick the History Rows for a given Person ID
    CURSOR c_person_history(p_person_id NUMBER) IS
    SELECT *
    FROM ghr_pa_history
    WHERE person_id = p_person_id
    AND (
           (table_name = 'PER_PEOPLE_EXTRA_INFO' and information5 = 'GHR_US_PER_GROUP1') OR
           (table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
             AND information4 IN (SELECT b.input_value_id
                                    FROM pay_element_types_f a,pay_input_values_f b
                                   WHERE a.element_type_id = b.element_type_id
                                     AND (
                                           (a.element_name = 'FEGLI' AND b.NAME = 'Eligibility Expiration') OR
                                           (a.element_name = 'Retirement Plan' AND b.NAME = 'FERS Eligibility Expires') OR
                                           (a.element_name = 'Health Benefits' and b.NAME in('LWOP Contingncy Strt Date','LWOP Contingncy End Date',
                                                                 'Child Eq Court Ord Date')) OR
                                           (a.element_name = 'Health Benefits Pre tax' and b.NAME in('LWOP Contingncy Strt Date','LWOP Contingncy End Date',
                                                                 'Child Eq Court Ord Date')) OR
                                           (a.element_name = 'TSP' and b.NAME in('Agncy Contrib Elig Date','Emp Contrib Elig Date'))
                                          )
                                 )
           )
       )
    ORDER BY effective_date,table_name,process_date,information1,pa_history_id;


    PROCEDURE print_ben_record(p_benefits_eit_rec IN ghr_api.per_benefit_info_type,p_person_id IN NUMBER,
                               p_effective_date IN DATE) IS
        BEGIN
           hr_utility.set_location('PERSON ID : '||to_char(p_person_id),500);
           hr_utility.set_location('Eff Date  : '||to_char(p_effective_date),505);
           hr_utility.set_location('FEGLI Date Elg Exp   : '|| p_benefits_eit_rec.FEGLI_Date_Eligibility_Expires,510);
           hr_utility.set_location('FEHB Date Elg Exp    : '|| p_benefits_eit_rec.FEHB_Date_Eligibility_expires,520);
           hr_utility.set_location('FEHB Date Temp Elg   : '|| p_benefits_eit_rec.FEHB_Date_temp_eligibility,530);
           hr_utility.set_location('FEHB Dte Dep Cer Exp : '|| p_benefits_eit_rec.FEHB_Date_dependent_cert_expir,540);
           hr_utility.set_location('FEHB LWOP Cont St Dt : '|| p_benefits_eit_rec.FEHB_LWOP_contingency_st_date,550);
           hr_utility.set_location('FEHB LWOP Cont Ed Dt : '|| p_benefits_eit_rec.FEHB_LWOP_contingency_end_date,560);
           hr_utility.set_location('FEHB Chld Eq Crt Dt  : '|| p_benefits_eit_rec.FEHB_Child_equiry_court_date,570);
           hr_utility.set_location('FERS Date Elg Exp    : '|| p_benefits_eit_rec.FERS_Date_eligibility_expires,580);
           hr_utility.set_location('FERS Election Dt     : '|| p_benefits_eit_rec.FERS_Election_Date,590);
           hr_utility.set_location('FERS Election Ind    : '|| p_benefits_eit_rec.FERS_Election_Indicator,600);
           hr_utility.set_location('TSP Agn Cont Elg Dt  : '|| p_benefits_eit_rec.TSP_Agncy_Contrib_Elig_date,610);
           hr_utility.set_location('TSP Emp Cont Elg Dt  : '|| p_benefits_eit_rec.TSP_Emp_Contrib_Elig_date,620);
    END print_ben_record;

    -- Procedure to get person Full Name, SSN
    PROCEDURE get_person_name_ssn(p_person_id           IN     per_people_f.person_id%TYPE
                                 ,p_effective_date      IN     DATE
                                 ,p_full_name           OUT NOCOPY  per_people_f.full_name%TYPE
                                 ,p_national_identifier OUT NOCOPY  per_people_f.national_identifier%TYPE
			                     ) IS
        CURSOR cur_per IS
          SELECT per.full_name
                ,per.national_identifier
          FROM   per_all_people_f per
          WHERE  per.person_id = p_person_id
          AND    NVL(p_effective_date,TRUNC(sysdate))  between per.effective_start_date
                                                          and per.effective_end_date;
    BEGIN
        FOR cur_per_rec IN cur_per LOOP
        p_full_name           := cur_per_rec.full_name;
        p_national_identifier := cur_per_rec.national_identifier;
        END LOOP;
    EXCEPTION
        WHEN others THEN
            p_full_name           := NULL ;
            p_national_identifier := NULL;
            RAISE;
    END get_person_name_ssn;

    -- Procedure to BUILD the intermediate Benefits Record
    PROCEDURE build_benefits_rec(p_pa_history_rec IN ghr_pa_history%rowtype,
                               p_benefits_eit_rec IN OUT nocopy ghr_api.per_benefit_info_type
                               ) IS

        l_benefits_eit_rec      ghr_api.per_benefit_info_type;
        l_element_name          VARCHAR2(150);
        l_input_value           VARCHAR2(150);
        l_input_value_id        NUMBER(20);

        CURSOR c_element_inpval(p_input_value_id NUMBER) IS
        SELECT a.element_name element, b.name input_value
          FROM pay_element_types_f a,pay_input_values_f b
         WHERE a.element_type_id = b.element_type_id
           AND b.input_value_id = p_input_value_id;


    BEGIN
        hr_utility.set_location('Entering build_benefits_rec',0);
        l_benefits_eit_rec := p_benefits_eit_rec;
        IF p_pa_history_rec.table_name = 'PER_PEOPLE_EXTRA_INFO' AND p_pa_history_rec.information5 = 'GHR_US_PER_GROUP1' THEN
            hr_utility.set_location('Assigning values for FEHB Person EIT',5);
            p_benefits_eit_rec.FEHB_Date_Eligibility_expires  := p_pa_history_rec.information19;
            p_benefits_eit_rec.FEHB_Date_temp_eligibility     := p_pa_history_rec.information20;
            p_benefits_eit_rec.FEHB_Date_dependent_cert_expir := p_pa_history_rec.information21;
        ELSIF p_pa_history_rec.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F' THEN
            l_element_name := NULL;
            l_input_value := NULL;
            l_input_value_id := p_pa_history_rec.information4;
            FOR element_inpval_rec IN c_element_inpval(l_input_value_id)
            LOOP
            l_element_name := element_inpval_rec.element;
            l_input_value := element_inpval_rec.input_value;
            EXIT;
            END LOOP;
            IF l_element_name = 'FEGLI' and l_input_value = 'Eligibility Expiration' THEN
                p_benefits_eit_rec.FEGLI_Date_Eligibility_Expires := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Retirement Plan' and l_input_value = 'FERS Eligibility Expires' THEN
                p_benefits_eit_rec.FERS_Date_eligibility_expires := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits' and l_input_value = 'LWOP Contingncy Strt Date' THEN
                p_benefits_eit_rec.FEHB_LWOP_contingency_st_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits' and l_input_value = 'LWOP Contingncy End Date' THEN
                p_benefits_eit_rec.FEHB_LWOP_contingency_end_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits' and l_input_value = 'Child Eq Court Ord Date' THEN
                p_benefits_eit_rec.FEHB_Child_equiry_court_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits Pre tax' and l_input_value = 'LWOP Contingncy Strt Date' THEN
                p_benefits_eit_rec.FEHB_LWOP_contingency_st_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits Pre tax' and l_input_value = 'LWOP Contingncy End Date' THEN
                p_benefits_eit_rec.FEHB_LWOP_contingency_end_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'Health Benefits Pre tax' and l_input_value = 'Child Eq Court Ord Date' THEN
                p_benefits_eit_rec.FEHB_Child_equiry_court_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'TSP' and l_input_value = 'Agncy Contrib Elig Date' THEN
                p_benefits_eit_rec.TSP_Agncy_Contrib_Elig_date := p_pa_history_rec.information6;
            ELSIF l_element_name = 'TSP' and l_input_value = 'Emp Contrib Elig Date' THEN
                p_benefits_eit_rec.TSP_Emp_Contrib_Elig_date := p_pa_history_rec.information6;
            END IF;
        ELSE
            -- SKIP the Record;
            NULL;
        END IF;
        hr_utility.set_location('Leaving build_benefits_rec',10);
    EXCEPTION
        WHEN OTHERS THEN
            p_benefits_eit_rec := l_benefits_eit_rec;
            RAISE;
    END build_benefits_rec;

    PROCEDURE insert_benefits_eit_rec(p_person_id      IN NUMBER,
                                      p_benefits_eit_rec   IN ghr_api.per_benefit_info_type,
                                      p_effective_date IN DATE) IS

        l_information_type      per_people_extra_info.information_type%type;
        l_person_extra_info_id  NUMBER;
        l_object_version_number NUMBER;

        CURSOR c_person_extra_info(p_person_id NUMBER) IS
        SELECT person_extra_info_id,
               object_version_number
          FROM per_people_extra_info
         WHERE person_id = p_person_id
           AND information_type = 'GHR_US_PER_BENEFIT_INFO';


    BEGIN
        hr_utility.set_location('Entering Insert benefits EIT REC',0);
        l_information_type := 'GHR_US_PER_BENEFIT_INFO';
        hr_utility.set_location('Calling Create Person Extra Info',10);
        FOR per_extra_info_rec IN c_person_extra_info(p_person_id)
        LOOP
           l_person_extra_info_id   :=  per_extra_info_rec.person_extra_info_id;
           l_object_version_number  :=  per_extra_info_rec.object_version_number;
        END LOOP;

        -- print_ben_record(p_benefits_eit_rec,p_person_id,p_effective_date);

        IF l_person_extra_info_id IS NULL THEN
            ghr_person_extra_info_api.create_person_extra_info
            (p_validate                      => false
            ,p_person_id                     => p_person_id
            ,p_information_type              => l_information_type
            ,p_effective_date                => p_effective_date
            ,p_pei_information_category      => l_information_type
            ,p_pei_information3              => p_benefits_eit_rec.FEGLI_Date_Eligibility_Expires
            ,p_pei_information4              => p_benefits_eit_rec.FEHB_Date_Eligibility_expires
            ,p_pei_information5              => p_benefits_eit_rec.FEHB_Date_temp_eligibility
            ,p_pei_information6              => p_benefits_eit_rec.FEHB_Date_dependent_cert_expir
            ,p_pei_information7              => p_benefits_eit_rec.FEHB_LWOP_contingency_st_date
            ,p_pei_information8              => p_benefits_eit_rec.FEHB_LWOP_contingency_end_date
            ,p_pei_information10              => p_benefits_eit_rec.FEHB_Child_equiry_court_date
            ,p_pei_information11             => p_benefits_eit_rec.FERS_Date_eligibility_expires
            ,p_pei_information12             => p_benefits_eit_rec.FERS_Election_Date
            ,p_pei_information13             => p_benefits_eit_rec.FERS_Election_Indicator
            ,p_pei_information14             => p_benefits_eit_rec.TSP_Agncy_Contrib_Elig_date
            ,p_pei_information15             => p_benefits_eit_rec.TSP_Emp_Contrib_Elig_date
            ,p_person_extra_info_id          => l_person_extra_info_id
            ,p_object_version_number         => l_object_version_number
            );
            hr_utility.set_location('Person Extra Info ID: '||to_char(l_person_extra_info_id),20);
            hr_utility.set_location('Object Version Number: '||to_char(l_object_version_number),30);
        ELSE
            ghr_person_extra_info_api.update_person_extra_info
            (p_person_extra_info_id    => l_person_extra_info_id
            ,p_object_version_number   => l_object_version_number
            ,p_effective_date          => p_effective_date
            ,p_pei_information3        => p_benefits_eit_rec.FEGLI_Date_Eligibility_Expires
            ,p_pei_information4        => p_benefits_eit_rec.FEHB_Date_Eligibility_expires
            ,p_pei_information5        => p_benefits_eit_rec.FEHB_Date_temp_eligibility
            ,p_pei_information6        => p_benefits_eit_rec.FEHB_Date_dependent_cert_expir
            ,p_pei_information7        => p_benefits_eit_rec.FEHB_LWOP_contingency_st_date
            ,p_pei_information8        => p_benefits_eit_rec.FEHB_LWOP_contingency_end_date
            ,p_pei_information10       => p_benefits_eit_rec.FEHB_Child_equiry_court_date
            ,p_pei_information11       => p_benefits_eit_rec.FERS_Date_eligibility_expires
            ,p_pei_information12       => p_benefits_eit_rec.FERS_Election_Date
            ,p_pei_information13       => p_benefits_eit_rec.FERS_Election_Indicator
            ,p_pei_information14       => p_benefits_eit_rec.TSP_Agncy_Contrib_Elig_date
            ,p_pei_information15       => p_benefits_eit_rec.TSP_Emp_Contrib_Elig_date
            );
        END IF;
        hr_utility.set_location('Leaving Insert Benefits EIT REC',40);
    END insert_benefits_eit_rec;

    -- ***************** MAIN PROGRAM ***************
BEGIN
    FOR s_id IN c_sessionid
    LOOP
        l_sid  := s_id.sesid;
        EXIT;
    END LOOP;

    BEGIN
        UPDATE fnd_sessions SET SESSION_ID = l_sid
        WHERE  SESSION_ID = l_sid;
        IF SQL%NOTFOUND THEN
            INSERT INTO fnd_sessions(SESSION_ID,EFFECTIVE_DATE)
            VALUES (l_sid,sysdate);
        END IF;
    END;

    --hr_utility.set_location('Entering the Conversion Process...',0);
    l_errbuf  := NULL;
    l_retcode := 0;
    l_per_err_cnt := 0;


    --
    --
    l_req := fnd_profile.VALUE ('CONC_REQUEST_ID');
    l_program_name := 'GHR_BEN_EIT_CREATION_'||l_req;
    l_dummy := 'y';
    -- Check whether the benefits information type is created or not.
    Open c_eit_exists;
    Fetch c_eit_exists into l_dummy;
    close c_eit_exists;

    IF l_dummy <> 'x' THEN
        p_errbuf  := 'Benefits EIT GHR_US_PER_BENEFIT_INFO is missing. ' ||
                   'Please run ghinfoty.sql and submit this concurrent program again.';
        p_retcode := 1;
    ELSE
        FOR federal_persons_rec IN c_batch_persons(p_session_id,p_batch_no)
        LOOP
            BEGIN
                l_current_person_id := federal_persons_rec.person_id;
                -- hr_utility.set_location('Processing Person '||to_char(l_current_person_id)||'....',20);
                -- initialise Benefits EIT Record
                l_benefits_eit_rec := NULL;
                l_new_effective_date := to_date('1900/01/01','YYYY/MM/DD');
                l_old_effective_date := to_date('1900/01/01','YYYY/MM/DD');
                l_cnt  := 0;
                OPEN c_person_history(l_current_person_id);
                LOOP
                    BEGIN
                        FETCH c_person_history INTO l_pa_history_rec;
                        l_cnt := l_cnt + 1;
                        IF c_person_history%FOUND THEN
                            --hr_utility.set_location('Processing history record '||to_char(l_pa_history_rec.pa_history_id)||'....',30);
                            --hr_utility.set_location('History record found',40);
                            l_new_effective_date := l_pa_history_rec.effective_date;
                            IF (l_new_effective_date = l_old_effective_date OR l_cnt = 1) THEN
                                build_benefits_rec(l_pa_history_rec,l_benefits_eit_rec);
                            ELSE
                               insert_benefits_eit_rec(l_current_person_id,l_benefits_eit_rec,l_old_effective_date);
                               build_benefits_rec(l_pa_history_rec,l_benefits_eit_rec);
                            END IF;
                            l_old_effective_date := l_new_effective_date;
                        ELSE
                            hr_utility.set_location('History record NOT found ...',50);
                            -- Added l_Cnt >1 condition. This is to check whether there are history records exists or not.
                            -- If no history record exists for a person, creation of benefits records can be skipped.
                            IF l_cnt > 1 THEN
                                insert_benefits_eit_rec(l_current_person_id,l_benefits_eit_rec,l_old_effective_date);
                            END IF;
                            -- print_ben_record(l_benefits_eit_rec,l_current_person_id,l_old_effective_date);
                            EXIT;
                        END IF;
                        --hr_utility.set_location('Completed Processing History Records. ',60);
                    EXCEPTION
                        WHEN OTHERS THEN
                            --hr_utility.set_location('Error Occured while processing history records',65);
                            Close c_person_history;
                            RAISE;
                    END;
                END LOOP; -- For Person_history_rec Cursor
                Close c_person_history;
                COMMIT;
                --hr_utility.set_location('Completed Processing for Person '||to_char(l_current_person_id),70);
            EXCEPTION
                WHEN OTHERS THEN
                    l_per_err_cnt := l_per_err_cnt + 1 ;
                    --hr_utility.set_location('Error Occured while processing Person ID',75);
                    get_person_name_ssn(l_current_person_id,l_new_effective_date,l_full_name,l_ssn);
                    l_log_text := 'System unable to create Benefits EIT for the Person: '||l_full_name||
                                  '; SSN: '||l_ssn||'; Error: '||sqlerrm;
                    ghr_wgi_pkg.create_ghr_errorlog (p_program_name => l_program_name
                                                    ,p_log_text     => l_log_text
                                                    ,p_message_name => 'Benefits EIT Creation Error'
                                                    ,p_log_date     => SYSDATE
                                                    );
                    COMMIT;
            END;
        END LOOP; -- For Person_rec Cursor

        -- Set Concurrent program completion messages
        IF l_per_err_cnt > 0 THEN
            p_retcode := 1;
            hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
            p_errbuf  := 'Unable to create benefits EIT for some person records. Please see the federal process log for details.';
        ELSE
            p_retcode := l_retcode;
            hr_utility.set_location('Ret code ' || to_char(l_retcode),1);
            p_errbuf  := 'Process Completed Successfully';
        END IF;

        -- Update the completion status.
        UPDATE GHR_MTS_TEMP
        SET completion_status = p_retcode
        WHERE session_id = p_session_id
        AND batch_no = p_batch_no;

        COMMIT;
    END IF; -- End of c_eit_exists%FOUND.
EXCEPTION
    WHEN OTHERS THEN
        hr_utility.set_location('ERROR Occured '||sqlerrm,100);
	    p_errbuf  := 'Process Errored Out with error message: '||sqlerrm;
        p_retcode := 2;
END execute_conversion;


PROCEDURE ValidateRun(p_result OUT nocopy varchar2) IS

     GHR_APPLICATION_ID constant   number:=8301;
     GHR_STATUS_INSTALLED constant varchar2(2):='I';

     cursor csr_ghr_installed is
     select status
     from fnd_product_installations
     where application_id = GHR_APPLICATION_ID;

     l_installed fnd_product_installations.status%type;
     l_result varchar2(10) ;

BEGIN
    l_result := 'FALSE';
    open csr_ghr_installed;
    fetch csr_ghr_installed into l_installed;
    if ( l_installed = GHR_STATUS_INSTALLED ) then
      l_result := 'TRUE';
    end if;
    close csr_ghr_installed;

    p_result  := l_result;
   --
END ValidateRun;



--Begin Bug# 6594288,6729058,7537134,9009719 Added this procedure for Concurrent program Process
-- Health Benefits Data Conversion

-- This Procedure is to end date or Create new elements pertaining to
-- Health Benefits and benefit pre tax elements.
PROCEDURE execute_conv_hlt_plan (   p_errbuf     OUT NOCOPY VARCHAR2,
                                    p_retcode    OUT NOCOPY NUMBER,
                                    p_business_group_id in Number) is

    l_assignment_id       pay_element_entries_f.assignment_id%type;
    l_req                 VARCHAR2 (25);
    l_ssn                 per_all_people_f.national_identifier%TYPE;
    l_program_name        ghr_process_log.program_name%TYPE;


    Cursor cur_ssn is
    SELECT ppf.national_identifier
       FROM per_assignments_f paf, per_people_f ppf
       WHERE ppf.person_id = paf.person_id
        AND paf.primary_flag = 'Y'
        AND paf.assignment_type <> 'B'
        AND to_date('2010/01/03','YYYY/MM/DD') BETWEEN paf.effective_start_date
                                 AND paf.effective_end_date
          AND to_date('2010/01/03','YYYY/MM/DD') BETWEEN ppf.effective_start_date
                                 AND ppf.effective_end_date
        AND paf.assignment_id =l_assignment_id;

    l_effective_date             date;
    l_name                       pay_input_values_f.name%type;
    l_input_value_id             pay_input_values_f.input_value_id%type;
    l_input_value_id_enrol       pay_input_values_f.input_value_id%type;
    l_effective_start_date       pay_element_entries_f.effective_start_date%type;
    l_effective_end_date         pay_element_entries_f.effective_end_date%type;
    l_element_entry_id           pay_element_entries_f.element_entry_id%type;
    l_object_version_number      pay_element_entries_f.object_version_number%type;
    l_screen_entry_value         pay_element_entry_values_f.screen_entry_value%type;
    l_screen_entry_value_enrol   pay_element_entry_values_f.screen_entry_value%type;
    l_effective_start_date_enrol   pay_element_entry_values_f.effective_start_date%type;
    l_effective_end_date_enrol   pay_element_entry_values_f.effective_end_date%type;
    l_business_group_id          per_assignments_f.business_group_id%type;
    l_update_flag                number := 0;
    l_health_plan_mod            number := 0;
    l_datetrack_update_mode      varchar2(25);

    l_out_effective_start_date   pay_element_entries_f.effective_start_date%type;
    l_out_effective_end_date     pay_element_entries_f.effective_end_date%type;
    l_out_update_warning         boolean;

    l_exists                     boolean := false;
    l_check_date                 date;

      Cursor c_get_ds_code is
  select dut.duty_station_code
  from   hr_location_extra_info lei,
         per_all_assignments_f asg,
         ghr_duty_stations_v dut
  where  asg.assignment_id = l_assignment_id
  and    l_effective_date between
         asg.effective_Start_date and asg.effective_end_date
  and    asg.location_id = lei.location_id
  and    lei.information_type = 'GHR_US_LOC_INFORMATION'
  and    lei.lei_information3 =  dut.duty_station_id
  and    dut.duty_station_code like '06%107'
  and    l_effective_date between
         dut.effective_start_date and dut.effective_end_date;
  l_duty_station_code	ghr_duty_stations_v.duty_station_code%type;

BEGIN
    l_req := fnd_profile.VALUE ('CONC_REQUEST_ID');
    l_program_name := 'GHR_HB_CNVR_'||l_req;
    -------------------------------------------------------------------------
    --Script for Health Plan changes
    -------------------------------------------------------------------------
    declare
    cursor cur_health_benefits is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id,--Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)--Bug# 6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in
           ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','SJ','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72');

    cursor cur_health_benefits_pt is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id, --Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id) --Bug#6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in
           ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','SJ','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72');

    cursor cur_hb_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in
             ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','SJ','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72');

    cursor cur_hb_pt_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in
            ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','SJ','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72');

    cursor cur_hb_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;


    cursor cur_hb_pt_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value,
           f.effective_start_date  effective_start_date,
           f.effective_end_date    effective_end_date
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_start_date = l_effective_start_date
    and    f.effective_end_date   = l_effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;


    BEGIN --A1

        l_update_flag      := 0;
        l_element_entry_id := null;
        l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');


       ----- A. Conversion.
        ----- Fetch the data pertaining to Health benefits element and the input value
        ----- is Health Plan

        for cur_health_benefits_rec in cur_health_benefits
        loop
            l_name                   := cur_health_benefits_rec.name;
            l_input_value_id         := cur_health_benefits_rec.input_value_id;
            l_effective_start_date   := cur_health_benefits_rec.effective_start_date;
            l_effective_end_date     := cur_health_benefits_rec.effective_end_date;
            l_check_date             := cur_health_benefits_rec.effective_end_date;
            l_element_entry_id       := cur_health_benefits_rec.element_entry_id;
            l_assignment_id          := cur_health_benefits_rec.assignment_id;
            l_business_group_id      := cur_health_benefits_rec.business_group_id;--Bug# 6735031
            l_object_version_number  := cur_health_benefits_rec.object_version_number;
            l_screen_entry_value     := cur_health_benefits_rec.screen_entry_value;

            for cur_hb_enroll_rec in cur_hb_enroll loop
                l_input_value_id_enrol     := cur_hb_enroll_rec.input_value_id;
                l_screen_entry_value_enrol := cur_hb_enroll_rec.screen_entry_value;
                exit;
            end loop;
            IF l_screen_entry_value in
                ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72') THEN
                l_update_flag        := 1;
                l_screen_entry_value_enrol := 'Y';
                l_screen_entry_value := 'ZZ';
            elsif l_screen_entry_value in ('SJ') THEN
				OPEN c_get_ds_code;
				FETCH c_get_ds_code into l_duty_station_code;
				IF c_get_ds_code%FOUND THEN
					l_update_flag        := 1;
					l_screen_entry_value := 'SI';
				ELSE
					l_update_flag        := 1;
					l_screen_entry_value_enrol := 'Y';
					l_screen_entry_value := 'ZZ';
				END IF;
				CLOSE c_get_ds_code;
	    end if;

           l_exists := false;

            if l_effective_start_date >= l_effective_date then
                l_datetrack_update_mode := 'CORRECTION';
                l_effective_date        := l_effective_start_date;
            elsif l_effective_start_date < l_effective_date  and
                to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31' then
                l_datetrack_update_mode := 'UPDATE';
                ----Check for future rows.
            elsif l_effective_start_date < l_effective_date then
                for update_mode_a in cur_hb_fr loop
                    l_exists := true;
                    exit;
                end loop;
                If l_exists then
                    l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                Else
                    l_datetrack_update_mode := 'UPDATE';
                End if;
            end if;

            if l_update_flag = 1 then
                l_update_flag := 0;
                BEGIN --A2
                    ghr_element_entry_api.update_element_entry
                        (  p_datetrack_update_mode         => l_datetrack_update_mode
                        ,p_effective_date                => l_effective_date
                        ,p_business_group_id             => l_business_group_id
                        ,p_element_entry_id              => l_element_entry_id
                        ,p_object_version_number         => l_object_version_number
                        ,p_input_value_id1               => l_input_value_id_enrol
                        ,p_entry_value1                  => l_screen_entry_value_enrol
                        ,p_input_value_id2               => l_input_value_id
                        ,p_entry_value2                  => l_screen_entry_value
                        ,p_effective_start_date          => l_out_effective_start_date
                        ,p_effective_end_date            => l_out_effective_end_date
                        ,p_update_warning                => l_out_update_warning
                        );
                    l_health_plan_mod := l_health_plan_mod + 1;
                    exception
                    when others then
                        for l_cur_ssn in cur_ssn loop
                            l_ssn := l_cur_ssn.national_identifier;
                            exit;
                        end loop;
                        ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'A. Upgrade for HB1-ERROR',
                            p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                        ' For SSN ' || l_ssn ||
                                        ' Element ' || to_char(l_element_entry_id) ||
                                        ' Assignment ' || to_char(l_assignment_id) ||
                                        ' SQLERR ' || SQLERRM,
                            p_log_date     => sysdate);
                    commit;
                END;--A2
            end if;
            l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
        end loop;
        BEGIN --A3
            if l_health_plan_mod <> 0 then
                ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => l_program_name,
                    p_message_name => 'A. Upgrade Script for HB1',
                    p_log_text     => 'Health Benefits Data Modified successfully....'
                                      || to_char(l_health_plan_mod) || ' rows',
                    p_log_date     => sysdate);
            else
                ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => l_program_name,
                    p_message_name => 'A. Upgrade Script for HB1',
                    p_log_text     => 'Health Benefits Data Not required to modify...',
                    p_log_date     => sysdate);
            end if;
            commit;
            exception
            when others then
                ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => l_program_name,
                    p_message_name => 'A. Upgrade Script for HB1',
                    p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                ' Element ' || to_char(l_element_entry_id) ||
                                ' Assignment ' || to_char(l_assignment_id) ||
                                ' SQLERR ' || SQLERRM,
                    p_log_date     => sysdate);
                commit;
        END; --A3

        ----- FOR 'Health Benefits Pre tax'
        l_update_flag      := 0;
        l_element_entry_id := null;
        l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');
        l_health_plan_mod  := 0;

        begin --B1
            ----- A. Conversion.
            ----- Fetch the data pertaining to Health benefits Pre tax element and the input value
            ----- is Health Plan

            for cur_health_benefits_pt_rec in cur_health_benefits_pt loop --Loop1
                l_name                   := cur_health_benefits_pt_rec.name;
                l_input_value_id         := cur_health_benefits_pt_rec.input_value_id;
                l_effective_start_date   := cur_health_benefits_pt_rec.effective_start_date;
                l_effective_end_date     := cur_health_benefits_pt_rec.effective_end_date;
                l_check_date             := cur_health_benefits_pt_rec.effective_end_date;
                l_element_entry_id       := cur_health_benefits_pt_rec.element_entry_id;
                l_assignment_id          := cur_health_benefits_pt_rec.assignment_id;
                l_business_group_id      := cur_health_benefits_pt_rec.business_group_id;--Bug# 6735031
                l_object_version_number  := cur_health_benefits_pt_rec.object_version_number;
                l_screen_entry_value     := cur_health_benefits_pt_rec.screen_entry_value;

                for cur_hb_pt_enroll_rec in cur_hb_pt_enroll loop
                    l_input_value_id_enrol     := cur_hb_pt_enroll_rec.input_value_id;
                    l_screen_entry_value_enrol := cur_hb_pt_enroll_rec.screen_entry_value;
                    exit;
                end loop;

                IF l_screen_entry_value in
                    ('A3','D6','TE','R3','J8','GE','MM','MU','2N','AK','CA','U2','S4','ED','FC','7T','2J','LK','DL','BP','RD','L8','GX','Y1','ND','LK','17','72') THEN
                    l_update_flag        := 1;
                    l_screen_entry_value_enrol := 'Y';
                    l_screen_entry_value := 'ZZ';
                elsif l_screen_entry_value in ('SJ') THEN
                    OPEN c_get_ds_code;
					FETCH c_get_ds_code into l_duty_station_code;
					IF c_get_ds_code%FOUND THEN
						l_update_flag        := 1;
						l_screen_entry_value := 'SI';
					ELSE
						l_update_flag        := 1;
						l_screen_entry_value_enrol := 'Y';
						l_screen_entry_value := 'ZZ';
					END IF;
					CLOSE c_get_ds_code;
		end if;

                l_exists := false;

                if l_effective_start_date >= l_effective_date then
                    l_datetrack_update_mode := 'CORRECTION';
                    l_effective_date        := l_effective_start_date;
                elsif   (l_effective_start_date < l_effective_date)  and
                        (to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31') then
                        l_datetrack_update_mode := 'UPDATE';
                        ----Check for future rows.
                elsif (l_effective_start_date < l_effective_date) then
                    for update_mode in cur_hb_pt_fr loop
                      l_exists := true;
                      exit;
                    end loop;
                    If l_exists then
                        l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                    Else
                        l_datetrack_update_mode := 'UPDATE';
                    End if;
                end if;

                if l_update_flag = 1 then
                    BEGIN --B2
                        l_update_flag := 0;
                        ghr_element_entry_api.update_element_entry
                            (  p_datetrack_update_mode         => l_datetrack_update_mode
                            ,p_effective_date                => l_effective_date
                            ,p_business_group_id             => l_business_group_id
                            ,p_element_entry_id              => l_element_entry_id
                            ,p_object_version_number         => l_object_version_number
                            ,p_input_value_id1               => l_input_value_id_enrol
                            ,p_entry_value1                  => l_screen_entry_value_enrol
                            ,p_input_value_id2               => l_input_value_id
                            ,p_entry_value2                  => l_screen_entry_value
                            ,p_effective_start_date          => l_out_effective_start_date
                            ,p_effective_end_date            => l_out_effective_end_date
                            ,p_update_warning                => l_out_update_warning
                            );
                        l_health_plan_mod := l_health_plan_mod + 1;
                        exception
                            when others then
                                 for l_cur_ssn in cur_ssn loop
                                    l_ssn := l_cur_ssn.national_identifier;
                                    exit;
                                end loop;
                                ghr_wgi_pkg.create_ghr_errorlog(
                                    p_program_name => l_program_name,
                                    p_message_name => 'A. Upgrade for HBPT1-ERROR',
                                    p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                                ' For SSN ' || l_ssn ||
                                                ' Element ' || to_char(l_element_entry_id) ||
                                                ' Assignment ' || to_char(l_assignment_id) ||
                                                ' SQLERR ' || SQLERRM,
                                    p_log_date     => sysdate);
                            commit;
                    END;--B2
                end if;
                l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
            end loop;--Loop1
            BEGIN --B3
                if l_health_plan_mod <> 0 then
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT1',
                        p_log_text     => 'Health Benefits Pre tax Data Modified successfully....'
                                  || to_char(l_health_plan_mod) || ' rows',
                        p_log_date     => sysdate);
                else
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT1',
                        p_log_text     => 'Health Benefits Pre tax Data Not required to modify...',
                        p_log_date     => sysdate);

                end if;
                commit;
                exception
                    when others then
                        ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT1',
                        p_log_text     => 'Error : Upgrade of Health Benefits Pre tax Error Processing ' ||
                                    ' Element ' || to_char(l_element_entry_id) ||
                                    ' Assignment ' || to_char(l_assignment_id) ||
                                    ' SQLERR ' || SQLERRM,
                        p_log_date     => sysdate);
                    commit;
            end;--B3
        END; --B1
     END; --A1

    ------------------------------------------------------------
    --Script for Only Enrolment changes
    ------------------------------------------------------------
    declare

    cursor cur_health_benefits is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id,--Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)--Bug# 6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in  ('FX','P2','SW','PN','11');

    cursor cur_health_benefits_pt is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id,--Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)--Bug# 6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in ('FX','P2','SW','PN','11');

    cursor cur_hb_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in   ('FX','P2','SW','PN','11');

    cursor cur_hb_pt_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in   ('FX','P2','SW','PN','11');

    cursor cur_hb_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;


    cursor cur_hb_pt_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value,
           f.effective_start_date  effective_start_date,
           f.effective_end_date    effective_end_date
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_start_date = l_effective_start_date
    and    f.effective_end_date   = l_effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;


    BEGIN --C1

        l_update_flag      := 0;
        l_element_entry_id := null;
        l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');
        l_health_plan_mod  := 0;

       ----- A. Conversion.
        ----- Fetch the data pertaining to Health benefits element and the input value
        ----- is Health Plan

        for cur_health_benefits_rec in cur_health_benefits
        loop
            l_name                   := cur_health_benefits_rec.name;
            l_input_value_id         := cur_health_benefits_rec.input_value_id;
            l_effective_start_date   := cur_health_benefits_rec.effective_start_date;
            l_effective_end_date     := cur_health_benefits_rec.effective_end_date;
            l_check_date             := cur_health_benefits_rec.effective_end_date;
            l_element_entry_id       := cur_health_benefits_rec.element_entry_id;
            l_assignment_id          := cur_health_benefits_rec.assignment_id;
            l_business_group_id      := cur_health_benefits_rec.business_group_id;--Bug# 6735031
            l_object_version_number  := cur_health_benefits_rec.object_version_number;
            l_screen_entry_value     := cur_health_benefits_rec.screen_entry_value;

             for cur_hb_enroll_rec in cur_hb_enroll loop
                l_input_value_id_enrol     := cur_hb_enroll_rec.input_value_id;
                l_screen_entry_value_enrol := cur_hb_enroll_rec.screen_entry_value;
                exit;
            end loop;

            IF l_screen_entry_value in ('FX','P2','11') THEN
                if l_screen_entry_value_enrol  in('4') then
                    l_update_flag        := 1;
                    l_screen_entry_value_enrol := '1';
                end if;
                if l_screen_entry_value_enrol  in('5') then
                    l_update_flag        := 1;
                    l_screen_entry_value_enrol := '2';
                end if;
            ELSIF l_screen_entry_value in ('SW','PN') THEN
                if l_screen_entry_value_enrol  in('1') then
                    l_update_flag        := 1;
                    l_screen_entry_value_enrol := '4';
                end if;
                if l_screen_entry_value_enrol  in('2') then
                    l_update_flag        := 1;
                    l_screen_entry_value_enrol := '5';
                end if;
            end if;

            l_exists := false;

            if l_effective_start_date >= l_effective_date then
                l_datetrack_update_mode := 'CORRECTION';
                l_effective_date        := l_effective_start_date;
            elsif l_effective_start_date < l_effective_date  and
                to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31' then
                l_datetrack_update_mode := 'UPDATE';
                ----Check for future rows.
            elsif l_effective_start_date < l_effective_date then
                for update_mode_a in cur_hb_fr loop
                    l_exists := true;
                    exit;
                end loop;
                If l_exists then
                    l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                Else
                    l_datetrack_update_mode := 'UPDATE';
                End if;
            end if;

            if l_update_flag = 1 then
                BEGIN --C2
                    l_update_flag := 0;
                    ghr_element_entry_api.update_element_entry
                        (  p_datetrack_update_mode         => l_datetrack_update_mode
                        ,p_effective_date                => l_effective_date
                        ,p_business_group_id             => l_business_group_id
                        ,p_element_entry_id              => l_element_entry_id
                        ,p_object_version_number         => l_object_version_number
                        ,p_input_value_id1               => l_input_value_id_enrol
                        ,p_entry_value1                  => l_screen_entry_value_enrol
                        ,p_effective_start_date          => l_out_effective_start_date
                        ,p_effective_end_date            => l_out_effective_end_date
                        ,p_update_warning                => l_out_update_warning
                        );
                    l_health_plan_mod := l_health_plan_mod + 1;
                    exception
                    when others then
                         for l_cur_ssn in cur_ssn loop
                            l_ssn := l_cur_ssn.national_identifier;
                            exit;
                        end loop;
                        ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'B. Upgrade for HB2-ERROR',
                            p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                        ' For SSN ' || l_ssn ||
                                        ' Element ' || to_char(l_element_entry_id) ||
                                        ' Assignment ' || to_char(l_assignment_id) ||
                                        ' SQLERR ' || SQLERRM,
                            p_log_date     => sysdate);
                    commit;
                END;--C2
            end if;
            l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
        end loop;
        BEGIN --C3
            if l_health_plan_mod <> 0 then
                ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => l_program_name,
                    p_message_name => 'A. Upgrade Script for HB2',
                    p_log_text     => 'Health Benefits Data Modified successfully....'
                              || to_char(l_health_plan_mod) || ' rows',
                    p_log_date     => sysdate);

            else
                ghr_wgi_pkg.create_ghr_errorlog(
                    p_program_name => l_program_name,
                    p_message_name => 'A. Upgrade Script for HB2',
                    p_log_text     => 'Health Benefits Data Not required to modify...',
                    p_log_date     => sysdate);
            end if;
            commit;
            exception
                when others then
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script for HB2',
                        p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                    ' Element ' || to_char(l_element_entry_id) ||
                                    ' Assignment ' || to_char(l_assignment_id) ||
                                    ' SQLERR ' || SQLERRM,
                        p_log_date     => sysdate);
                    commit;
        END; --C3
        ----- FOR 'Health Benefits Pre tax'
        l_update_flag      := 0;
        l_element_entry_id := null;
        l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');
        l_health_plan_mod  := 0;

        begin --C4
            ----- A. Conversion.
            ----- Fetch the data pertaining to Health benefits Pre tax element and the input value
            ----- is Health Plan

            for cur_health_benefits_pt_rec in cur_health_benefits_pt loop
                l_name                   := cur_health_benefits_pt_rec.name;
                l_input_value_id         := cur_health_benefits_pt_rec.input_value_id;
                l_effective_start_date   := cur_health_benefits_pt_rec.effective_start_date;
                l_effective_end_date     := cur_health_benefits_pt_rec.effective_end_date;
                l_check_date             := cur_health_benefits_pt_rec.effective_end_date;
                l_element_entry_id       := cur_health_benefits_pt_rec.element_entry_id;
                l_assignment_id          := cur_health_benefits_pt_rec.assignment_id;
                l_business_group_id      := cur_health_benefits_pt_rec.business_group_id;--Bug# 6735031
                l_object_version_number  := cur_health_benefits_pt_rec.object_version_number;
                l_screen_entry_value     := cur_health_benefits_pt_rec.screen_entry_value;

                for cur_hb_pt_enroll_rec in cur_hb_pt_enroll loop
                    l_input_value_id_enrol     := cur_hb_pt_enroll_rec.input_value_id;
                    l_screen_entry_value_enrol := cur_hb_pt_enroll_rec.screen_entry_value;
                    exit;
                end loop;
                IF l_screen_entry_value in ('FX','P2','11') THEN
                    if l_screen_entry_value_enrol  in('4') then
                        l_update_flag        := 1;
                        l_screen_entry_value_enrol := '1';
                    end if;
                    if l_screen_entry_value_enrol  in('5') then
                        l_update_flag        := 1;
                        l_screen_entry_value_enrol := '2';
                    end if;
                ELSIF l_screen_entry_value in ('SW','PN') THEN
                    if l_screen_entry_value_enrol  in('1') then
                        l_update_flag        := 1;
                        l_screen_entry_value_enrol := '4';
                    end if;
                    if l_screen_entry_value_enrol  in('2') then
                        l_update_flag        := 1;
                        l_screen_entry_value_enrol := '5';
                    end if;
                end if;

                l_exists := false;

                if l_effective_start_date >= l_effective_date then
                    l_datetrack_update_mode := 'CORRECTION';
                    l_effective_date        := l_effective_start_date;
                elsif   (l_effective_start_date < l_effective_date)  and
                        (to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31') then
                        l_datetrack_update_mode := 'UPDATE';
                        ----Check for future rows.
                elsif (l_effective_start_date < l_effective_date) then
                    for update_mode in cur_hb_pt_fr loop
                      l_exists := true;
                      exit;
                    end loop;
                    If l_exists then
                        l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                    Else
                        l_datetrack_update_mode := 'UPDATE';
                    End if;
                end if;

                if l_update_flag = 1 then
                    BEGIN --C5
                        l_update_flag := 0;
                        ghr_element_entry_api.update_element_entry
                            (  p_datetrack_update_mode         => l_datetrack_update_mode
                            ,p_effective_date                => l_effective_date
                            ,p_business_group_id             => l_business_group_id
                            ,p_element_entry_id              => l_element_entry_id
                            ,p_object_version_number         => l_object_version_number
                            ,p_input_value_id1               => l_input_value_id_enrol
                            ,p_entry_value1                  => l_screen_entry_value_enrol
                            ,p_effective_start_date          => l_out_effective_start_date
                            ,p_effective_end_date            => l_out_effective_end_date
                            ,p_update_warning                => l_out_update_warning
                            );
                        l_health_plan_mod := l_health_plan_mod + 1;
                    exception
                    when others then
                         for l_cur_ssn in cur_ssn loop
                            l_ssn := l_cur_ssn.national_identifier;
                            exit;
                        end loop;
                        ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade for HBPT2-ERROR',
                        p_log_text     => 'Error : Upgrade of Health Benefits Pre tax Error Processing ' ||
                                    ' For SSN ' || l_ssn ||
                                    ' Element ' || to_char(l_element_entry_id) ||
                                    ' Assignment ' || to_char(l_assignment_id) ||
                                    ' SQLERR ' || SQLERRM,
                        p_log_date     => sysdate);
                        commit;
                    END; --C5
                end if;
                l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
            end loop;
            BEGIN --C6
                if l_health_plan_mod <> 0 then
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT2',
                        p_log_text     => 'Health Benefits Pre tax Data Modified successfully....'
                                  || to_char(l_health_plan_mod) || ' rows',
                        p_log_date     => sysdate);
                else
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT2',
                        p_log_text     => 'Health Benefits Pre tax Data Not required to modify...',
                        p_log_date     => sysdate);

                end if;
                commit;
                exception
                    when others then
                        ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script HBPT2',
                        p_log_text     => 'Error : Upgrade of Health Benefits Pre tax Error Processing ' ||
                                    ' Element ' || to_char(l_element_entry_id) ||
                                    ' Assignment ' || to_char(l_assignment_id) ||
                                    ' SQLERR ' || SQLERRM,
                        p_log_date     => sysdate);
                    commit;

            end; --C6
        END; --C4
     END; --C1
     ------------------------------------------------------------
    --Script for Only Health Plan changes
    ------------------------------------------------------------
    declare

    cursor cur_health_benefits is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id,--Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)--Bug# 6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in  ('VR','FM');

    cursor cur_health_benefits_pt is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           c.business_group_id        business_group_id,--Bug# 6735031
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)--Bug# 6735031
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in ('VR','FM');

    cursor cur_hb_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in   ('VR','FM');

    cursor cur_hb_pt_fr is
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Health Plan'
    and    f.screen_entry_value in   ('VR','FM');

    cursor cur_hb_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;


    cursor cur_hb_pt_enroll is
    select f.input_value_id        input_value_id,
           f.screen_entry_value    screen_entry_value,
           f.effective_start_date  effective_start_date,
           f.effective_end_date    effective_end_date
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(l_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    f.effective_start_date = l_effective_start_date
    and    f.effective_end_date   = l_effective_end_date
    and    f.effective_end_date   > to_date('2010/01/02','YYYY/MM/DD')
    and    a.element_name         = 'Health Benefits Pre tax'
    and    b.name                 = 'Enrollment'
    and    e.element_entry_id     = l_element_entry_id;

    BEGIN --D1
        l_update_flag      := 0;
        l_element_entry_id := null;
        l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');
        l_health_plan_mod  := 0;

            ----- A. Conversion.
            ----- Fetch the data pertaining to Health benefits element and the input value
            ----- is Health Plan

            for cur_health_benefits_rec in cur_health_benefits
            loop
                l_name                   := cur_health_benefits_rec.name;
                l_input_value_id         := cur_health_benefits_rec.input_value_id;
                l_effective_start_date   := cur_health_benefits_rec.effective_start_date;
                l_effective_end_date     := cur_health_benefits_rec.effective_end_date;
                l_check_date             := cur_health_benefits_rec.effective_end_date;
                l_element_entry_id       := cur_health_benefits_rec.element_entry_id;
                l_assignment_id          := cur_health_benefits_rec.assignment_id;
                l_business_group_id      := cur_health_benefits_rec.business_group_id;--Bug# 6735031
                l_object_version_number  := cur_health_benefits_rec.object_version_number;
                l_screen_entry_value     := cur_health_benefits_rec.screen_entry_value;

                for cur_hb_enroll_rec in cur_hb_enroll loop
                    l_input_value_id_enrol     := cur_hb_enroll_rec.input_value_id;
                    l_screen_entry_value_enrol := cur_hb_enroll_rec.screen_entry_value;
                    exit;
                end loop;
                if l_screen_entry_value in ('VR') and l_screen_entry_value_enrol in('1','2','4','5') then
                  l_update_flag        := 1;
                  l_screen_entry_value := '54';
                end if;
		if l_screen_entry_value in ('FM') and l_screen_entry_value_enrol in('1','2') then
                  l_update_flag        := 1;
                  l_screen_entry_value := 'FX';
                end if;

                l_exists := false;

                if l_effective_start_date >= l_effective_date then
                    l_datetrack_update_mode := 'CORRECTION';
                    l_effective_date        := l_effective_start_date;
                elsif l_effective_start_date < l_effective_date  and
                    to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31' then
                    l_datetrack_update_mode := 'UPDATE';
                    ----Check for future rows.
                elsif l_effective_start_date < l_effective_date then
                    for update_mode_a in cur_hb_fr loop
                        l_exists := true;
                        exit;
                    end loop;
                    If l_exists then
                        l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                    Else
                        l_datetrack_update_mode := 'UPDATE';
                    End if;
                end if;

                if l_update_flag = 1 then
                    BEGIN --D2
                        l_update_flag := 0;
                        ghr_element_entry_api.update_element_entry
                            (  p_datetrack_update_mode         => l_datetrack_update_mode
                            ,p_effective_date                => l_effective_date
                            ,p_business_group_id             => l_business_group_id
                            ,p_element_entry_id              => l_element_entry_id
                            ,p_object_version_number         => l_object_version_number
                            ,p_input_value_id1               => l_input_value_id
                            ,p_entry_value1                  => l_screen_entry_value
                            ,p_effective_start_date          => l_out_effective_start_date
                            ,p_effective_end_date            => l_out_effective_end_date
                            ,p_update_warning                => l_out_update_warning
                            );
                        l_health_plan_mod := l_health_plan_mod + 1;
                    exception
                    when others then
                         for l_cur_ssn in cur_ssn loop
                            l_ssn := l_cur_ssn.national_identifier;
                            exit;
                        end loop;
                        ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade for HB3-ERROR',
                        p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                    ' For SSN ' || l_ssn ||
                                    ' Element ' || to_char(l_element_entry_id) ||
                                    ' Assignment ' || to_char(l_assignment_id) ||
                                    ' SQLERR ' || SQLERRM,
                        p_log_date     => sysdate);
                        commit;
                    END; --D2
                end if;
                l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
            end loop;
            BEGIN --D3
                if l_health_plan_mod <> 0 then
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script for HB3',
                        p_log_text     => 'Health Benefits Data Modified successfully....'
                                  || to_char(l_health_plan_mod) || ' rows',
                        p_log_date     => sysdate);

                else
                    ghr_wgi_pkg.create_ghr_errorlog(
                        p_program_name => l_program_name,
                        p_message_name => 'A. Upgrade Script for HB3',
                        p_log_text     => 'Health Benefits Data Not required to modify...',
                        p_log_date     => sysdate);
                end if;
                commit;
                exception
                    when others then
                        ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'A. Upgrade Script for HB3',
                            p_log_text     => 'Error : Upgrade of Health Benefits Error Processing ' ||
                                        ' Element ' || to_char(l_element_entry_id) ||
                                        ' Assignment ' || to_char(l_assignment_id) ||
                                        ' SQLERR ' || SQLERRM,
                            p_log_date     => sysdate);
                        commit;
            END; --D3

            ----- FOR 'Health Benefits Pre tax'
            l_update_flag      := 0;
            l_element_entry_id := null;
            l_effective_date   := to_date('2010/01/03','YYYY/MM/DD');
            l_health_plan_mod  := 0;

            begin --D4
                ----- A. Conversion.
                ----- Fetch the data pertaining to Health benefits Pre tax element and the input value
                ----- is Health Plan

                for cur_health_benefits_pt_rec in cur_health_benefits_pt loop
                    l_name                   := cur_health_benefits_pt_rec.name;
                    l_input_value_id         := cur_health_benefits_pt_rec.input_value_id;
                    l_effective_start_date   := cur_health_benefits_pt_rec.effective_start_date;
                    l_effective_end_date     := cur_health_benefits_pt_rec.effective_end_date;
                    l_check_date             := cur_health_benefits_pt_rec.effective_end_date;
                    l_element_entry_id       := cur_health_benefits_pt_rec.element_entry_id;
                    l_assignment_id          := cur_health_benefits_pt_rec.assignment_id;
                    l_business_group_id      := cur_health_benefits_pt_rec.business_group_id;--Bug# 6735031
                    l_object_version_number  := cur_health_benefits_pt_rec.object_version_number;
                    l_screen_entry_value     := cur_health_benefits_pt_rec.screen_entry_value;

                    for cur_hb_pt_enroll_rec in cur_hb_pt_enroll loop
                        l_input_value_id_enrol     := cur_hb_pt_enroll_rec.input_value_id;
                        l_screen_entry_value_enrol := cur_hb_pt_enroll_rec.screen_entry_value;
                        exit;
                    end loop;
                    if l_screen_entry_value in ('VR') and l_screen_entry_value_enrol in('1','2','4','5') then
                      l_update_flag        := 1;
                      l_screen_entry_value := '54';
                    end if;
		     if l_screen_entry_value in ('FM') and l_screen_entry_value_enrol in('1','2') then
                      l_update_flag        := 1;
                      l_screen_entry_value := 'FX';
                    end if;

                    l_exists := false;

                    if l_effective_start_date >= l_effective_date then
                        l_datetrack_update_mode := 'CORRECTION';
                        l_effective_date        := l_effective_start_date;
                    elsif   (l_effective_start_date < l_effective_date)  and
                            (to_char(l_effective_end_date,'YYYY/MM/DD') = '4712/12/31') then
                            l_datetrack_update_mode := 'UPDATE';
                            ----Check for future rows.
                    elsif (l_effective_start_date < l_effective_date) then
                        for update_mode in cur_hb_pt_fr loop
                          l_exists := true;
                          exit;
                        end loop;
                        If l_exists then
                            l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
                        Else
                            l_datetrack_update_mode := 'UPDATE';
                        End if;
                    end if;

                    if l_update_flag = 1 then
                        BEGIN --D5
                            l_update_flag := 0;
                            ghr_element_entry_api.update_element_entry
                                (  p_datetrack_update_mode         => l_datetrack_update_mode
                                ,p_effective_date                => l_effective_date
                                ,p_business_group_id             => l_business_group_id
                                ,p_element_entry_id              => l_element_entry_id
                                ,p_object_version_number         => l_object_version_number
                                ,p_input_value_id1               => l_input_value_id
                                ,p_entry_value1                  => l_screen_entry_value
                                ,p_effective_start_date          => l_out_effective_start_date
                                ,p_effective_end_date            => l_out_effective_end_date
                                ,p_update_warning                => l_out_update_warning
                                );
                            l_health_plan_mod := l_health_plan_mod + 1;
                            exception
                            when others then
                                for l_cur_ssn in cur_ssn loop
                                    l_ssn := l_cur_ssn.national_identifier;
                                    exit;
                                end loop;
                                ghr_wgi_pkg.create_ghr_errorlog(
                                p_program_name => l_program_name,
                                p_message_name => 'A. Upgrade for HBPT3-ERROR',
                                p_log_text    => 'Error : Upgrade of Health Benefits Pre tax Error Processing '||
                                            ' For SSN ' || l_ssn ||
                                            ' Element ' || to_char(l_element_entry_id) ||
                                            ' Assignment ' || to_char(l_assignment_id) ||
                                            ' SQLERR ' || SQLERRM,
                                p_log_date     => sysdate);
                            commit;
                        END; --D5
                    end if;
                    l_effective_date  := to_date('2010/01/03','YYYY/MM/DD');
                end loop;
                BEGIN --D6
                    if l_health_plan_mod <> 0 then
                        ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'A. Upgrade Script HBPT3',
                            p_log_text     => 'Health Benefits Pre tax Data Modified successfully....'
                                      || to_char(l_health_plan_mod) || ' rows',
                            p_log_date     => sysdate);
                    else
                        ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'A. Upgrade Script HBPT3',
                            p_log_text     => 'Health Benefits Pre tax Data Not required to modify...',
                            p_log_date     => sysdate);

                    end if;
                    commit;
                    exception
                        when others then
                            ghr_wgi_pkg.create_ghr_errorlog(
                            p_program_name => l_program_name,
                            p_message_name => 'A. Upgrade Script HBPT3',
                            p_log_text     => 'Error : Upgrade of Health Benefits Pre tax Error Processing ' ||
                                        ' Element ' || to_char(l_element_entry_id) ||
                                        ' Assignment ' || to_char(l_assignment_id) ||
                                        ' SQLERR ' || SQLERRM,
                            p_log_date     => sysdate);
                        commit;
                end; --D6
            END; --D4
     END; --D1

END execute_conv_hlt_plan;

--End Bug# 7537134,9009719
-- to see Bug# 6594288,6729058 changes open version 115.10
--Begin Bug# 8622486
PROCEDURE execute_tsp_conversion (p_errbuf     OUT NOCOPY VARCHAR2,
                                    p_retcode    OUT NOCOPY NUMBER,
                                    p_business_group_id in Number,
				    p_agency_effective_date in varchar2,
				    p_agency_code  IN varchar2,
				    p_agency_sub_code IN varchar2) IS

l_assignment_id			pay_element_entries_f.assignment_id%type;
l_position_id			per_all_assignments_f.position_id%type;
l_person_id			per_all_assignments_f.person_id%type;
l_agncy_contrib_elig_date	per_people_extra_info.pei_information14%type;
l_effective_start_date		per_all_people_f.effective_start_date%type;
l_effective_end_date		per_all_people_f.effective_end_date%type;
l_retirement_plan		pay_element_entry_values_f.screen_entry_value%type;
l_agency_effective_date		date;
l_calculated_date		date;
l_req                 VARCHAR2 (25);
l_program_name        ghr_process_log.program_name%TYPE;


l_effective_date             date;

l_name                       pay_input_values_f.name%type;
l_input_value_id             pay_input_values_f.input_value_id%type;
l_tsp_start_date	     pay_element_entry_values_f.screen_entry_value%type;
l_elmnt_effective_start_date   pay_element_entries_f.effective_start_date%type;
l_elmnt_effective_end_date     pay_element_entries_f.effective_end_date%type;
l_element_entry_id           pay_element_entries_f.element_entry_id%type;
l_object_version_number      pay_element_entries_f.object_version_number%type;
l_screen_entry_value         pay_element_entry_values_f.screen_entry_value%type;
l_business_group_id          per_assignments_f.business_group_id%type;
l_update_flag                number := 0;
l_cotrib_update_flag         number := 0;
l_elig_date_flag	     number := 0;
l_datetrack_update_mode      varchar2(25);

l_out_effective_start_date   pay_element_entries_f.effective_start_date%type;
l_out_effective_end_date     pay_element_entries_f.effective_end_date%type;
l_out_update_warning         boolean;

l_exists                     boolean := false;
l_check_date                 date;
l_employee_number	     per_all_people_f.national_identifier%type;
l_employee_name		     per_all_people_f.full_name%type;

l_tsp_abv_agcy_rec_cnt  number :=0;
l_tsp_future_rec_cnt  number :=0;
l_process_log_upd_flag  number :=0;

CURSOR c_tsp_agncy_date IS
select paf.position_id,ppf.person_id,paf.assignment_id,
ppei.pei_information14 ,ppf.effective_start_date, ppf.effective_end_date,ppf.national_identifier,
ppf.full_name
from per_all_people_f ppf, per_all_assignments_f paf, per_people_extra_info ppei
where ppf.person_id=paf.person_id
and ppf.person_id=ppei.person_id
and ppei.information_type='GHR_US_PER_BENEFIT_INFO'
and paf.primary_flag='Y'
and paf.assignment_type<>'B'
and ppf.current_employee_flag='Y'
and ppf.effective_end_date > l_agency_effective_date
--and fnd_date.canonical_to_date(ppei.pei_information14) >= l_agency_effective_date
and ppei.pei_information14 IS NOT NULL
and ppf.business_group_id=paf.business_group_id
and ppf.business_group_id= NVL(p_business_group_id,ppf.business_group_id)
AND ghr_api.get_position_agency_code_pos(paf.position_id,paf.business_group_id) like SUBSTR(p_agency_code,1,2)||SUBSTR(p_agency_sub_code,1,2)||'%' ;

l_rpa_effective_date             ghr_pa_requests.effective_date%type;
l_rpa_tsp_status_code             ghr_pa_request_extra_info.rei_information15%type;
l_rpa_agncy_contrib_elig_date     ghr_pa_request_extra_info.rei_information17%type;
l_pa_request_id			ghr_pa_requests.pa_request_id%type;

CURSOR c_future_actions IS
SELECT pa.pa_request_id,
pa_ei.rei_information17, pa_ei.rei_information15,
pa.effective_date
FROM ghr_pa_request_extra_info pa_ei, ghr_pa_requests pa
WHERE pa_ei.information_type='GHR_US_PAR_BENEFITS'
AND pa.noa_family_code in ('APP','CONV_APP')
AND pa.RETIREMENT_PLAN  IN('K','L','M','N')
AND pa.effective_date > sysdate
AND pa_ei.pa_request_id=pa.pa_request_id
AND status ='FUTURE_ACTION'
AND NVL(pa.agency_code,pa.from_agency_code) LIKE SUBSTR(p_agency_code,1,2)||SUBSTR(p_agency_sub_code,1,2)||'%' ;

CURSOR c_get_tsp_value IS
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           c.business_group_id        business_group_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_agency_effective_date
    and    a.element_name         = 'TSP'
    and    b.name                 = 'Status'
    and    e.assignment_id	  = l_assignment_id ;

CURSOR c_get_future_tsp_value IS
    select b.name                     name,
           f.input_value_id           input_value_id,
           e.effective_start_date     effective_start_date,
           e.effective_end_date       effective_end_date,
           e.element_entry_id         element_entry_id,
           e.assignment_id            assignment_id,
           e.object_version_number    object_version_number,
           f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_check_date
    and    e.element_entry_id     = l_element_entry_id
    and    a.element_name         = 'TSP'
    and    b.name                 = 'Status'
    and    e.assignment_id	  = l_assignment_id
    and    e.element_entry_id     = l_element_entry_id;

CURSOR c_get_tsp_date IS
    select f.screen_entry_value       screen_entry_value
    from   pay_element_types_f        a,
           pay_input_values_f         b,
           pay_element_links_f        c,
           pay_link_input_values_f    d,
           pay_element_entries_f      e,
           pay_element_entry_values_f f
    where  a.element_type_id      = b.element_type_id
    and    a.element_type_id      = c.element_type_id
    and    c.element_link_id      = d.element_link_id
    and    b.input_value_id       = d.input_value_id
    and    e.element_link_id      = c.element_link_id
    and    f.element_entry_id     = e.element_entry_id
    and    f.input_value_id       = b.input_value_id
    and    c.business_group_id    = nvl(p_business_group_id,c.business_group_id)
    and    e.effective_start_date = f.effective_start_date
    and    e.effective_end_date   = f.effective_end_date
    and    e.effective_end_date   > l_agency_effective_date
    and    a.element_name         = 'TSP'
    and    b.name                 = 'Status Date'
    and    e.assignment_id	  = l_assignment_id ;


l_session_var	ghr_history_api.g_session_var_type;
l_sess_date  DATE;
l_session_id number;
l_peopleei_data  per_people_extra_info%rowtype;

cursor get_sess_date is
    select trunc(effective_date)
    from   fnd_sessions
    where  session_id = l_session_id;

cursor c_peopleei_getovn(cp_people_ei_id  number) is
       select object_version_number
       from per_people_extra_info
       where person_extra_info_id = cp_people_ei_id;

BEGIN
	l_req := fnd_profile.VALUE ('CONC_REQUEST_ID');
	l_program_name := 'GHR_TSP_CONV_'||l_req;
	l_agency_effective_date := fnd_date.canonical_to_date(p_agency_effective_date);
	BEGIN --B1
		l_tsp_abv_agcy_rec_cnt:=0;
		for l_tsp_agncy_date in c_tsp_agncy_date LOOP
			l_process_log_upd_flag:=0;
			l_assignment_id :=  l_tsp_agncy_date.assignment_id;
			l_position_id	:=  l_tsp_agncy_date.position_id;
			l_person_id	:=  l_tsp_agncy_date.person_id;
			l_agncy_contrib_elig_date	:=  l_tsp_agncy_date.pei_information14;
			l_effective_start_date		:=  l_tsp_agncy_date.effective_start_date;
			l_effective_end_date		:=  l_tsp_agncy_date.effective_end_date;
			l_employee_number		:= l_tsp_agncy_date.national_identifier;
			l_employee_name			:= l_tsp_agncy_date.full_name;

		IF  fnd_date.canonical_to_date(l_agncy_contrib_elig_date) >= l_agency_effective_date THEN
				IF l_agency_effective_date < l_effective_start_date THEN
					l_calculated_date := l_effective_start_date;
				ELSE
					l_calculated_date:= l_agency_effective_date;
				END IF;
				GHR_HISTORY_FETCH.fetch_element_entry_value(
					p_element_name       =>  'Retirement Plan',
					p_input_value_name   =>  'Plan',
					p_assignment_id      =>  l_assignment_id,
					p_date_effective     =>  l_calculated_date,
					p_screen_entry_value =>  l_retirement_plan
					);
			IF l_retirement_plan IN('K','L', 'M', 'N') THEN
				BEGIN --B2
					l_update_flag      := 0;
					l_cotrib_update_flag :=0;
					l_element_entry_id := null;
					l_effective_date   := l_agency_effective_date;

					for l_get_tsp_value in c_get_tsp_value
					LOOP
						l_name                   := l_get_tsp_value.name;
						l_input_value_id         := l_get_tsp_value.input_value_id;
						l_elmnt_effective_start_date   := l_get_tsp_value.effective_start_date;
						l_elmnt_effective_end_date     := l_get_tsp_value.effective_end_date;
						l_check_date             := l_get_tsp_value.effective_end_date;
						l_element_entry_id       := l_get_tsp_value.element_entry_id;
						l_business_group_id      := l_get_tsp_value.business_group_id;
						l_object_version_number  := l_get_tsp_value.object_version_number;
						l_screen_entry_value     := l_get_tsp_value.screen_entry_value;

						IF l_screen_entry_value = ('I') THEN
							l_update_flag        := 1;
							l_screen_entry_value := 'E';
						ELSIF l_screen_entry_value = ('W') THEN
							l_update_flag        := 1;
							l_screen_entry_value := 'Y';
						ELSIF l_screen_entry_value = ('S') THEN
							l_update_flag        := 1;
							l_screen_entry_value := 'T';
						END IF;

						l_exists := false;

						if l_elmnt_effective_start_date >= l_effective_date then
							l_datetrack_update_mode := 'CORRECTION';
						elsif l_elmnt_effective_start_date < l_effective_date  and
							to_char(l_elmnt_effective_end_date,'YYYY/MM/DD') = '4712/12/31' then
							l_datetrack_update_mode := 'UPDATE';
						----Check for future rows.
						elsif l_elmnt_effective_start_date < l_effective_date then
							for l_get_future_tsp_value in c_get_future_tsp_value loop
								l_exists := true;
								exit;
							end loop;
							If l_exists then
								l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
							Else
								l_datetrack_update_mode := 'UPDATE';
							End if;
						end if;

						if l_update_flag = 1 then
							l_update_flag := 0;
							BEGIN --B3
								ghr_element_entry_api.update_element_entry
									(  p_datetrack_update_mode       => l_datetrack_update_mode
									,p_effective_date                => l_calculated_date
									,p_business_group_id             => l_business_group_id
									,p_element_entry_id              => l_element_entry_id
									,p_object_version_number         => l_object_version_number
									,p_input_value_id3               => l_input_value_id
									,p_entry_value3                  => l_screen_entry_value
									,p_effective_start_date          => l_out_effective_start_date
									,p_effective_end_date            => l_out_effective_end_date
									,p_update_warning                => l_out_update_warning
									);

								l_tsp_abv_agcy_rec_cnt := l_tsp_abv_agcy_rec_cnt + 1;
								IF (fnd_date.canonical_to_date(l_agncy_contrib_elig_date) >= l_agency_effective_date
									AND  fnd_date.canonical_to_date(l_agncy_contrib_elig_date)  < SYSDATE) THEN
									FOR l_get_tsp_date IN c_get_tsp_date LOOP
										l_tsp_start_date := l_get_tsp_date.screen_entry_value;
										EXIT;
									END LOOP;
									l_process_log_upd_flag:=1;
									ghr_wgi_pkg.create_ghr_errorlog(
											p_program_name => l_program_name,
											p_message_name => 'Upgrade for TSP-Warning',
											p_log_text     => 'Warning : Please verify the TSP Status Start Date ' ||
											' For Person Name ' || l_employee_name ||
											' SSN ' || l_employee_number ||
											' system date ' || to_char(sysdate,'DD-MON-RRRR') ||
											' TSP Agency Contrib Elig Date ' || l_calculated_date ||
											' TSP status ' || l_screen_entry_value ||
											' TSP status start Date ' || l_tsp_start_date ||
											' Agency Effective Date ' || l_agency_effective_date,
											p_log_date     => sysdate);
								END IF;
								exception
								when others then
									ghr_wgi_pkg.create_ghr_errorlog(
										p_program_name => l_program_name,
										p_message_name => 'Upgrade for TSP-ERROR',
										p_log_text     => 'Error : Upgrade of TSP Error Processing ' ||
										' For SSN ' || l_employee_number ||
										' Element ' || to_char(l_element_entry_id) ||
										' Assignment ' || to_char(l_assignment_id) ||
										' SQLERR ' || SQLERRM,
										p_log_date     => sysdate);
								commit;
							END;--B3
						end if;
					end loop;

				END; --B2
				BEGIN --B4

					ghr_history_api.reinit_g_session_var;
					l_session_var.person_id := l_person_id;
					l_session_var.assignment_id  := l_assignment_id;
					l_session_var.program_name := 'core';
					l_session_var.date_effective := trunc(l_calculated_date);
					l_session_var.fire_trigger := 'Y';
					ghr_history_api.set_g_session_var (l_session_var);

					select userenv('sessionid')  INTO l_session_id from dual;
					open get_sess_date;
					fetch get_sess_date into l_sess_date;
					IF get_sess_date%NOTFOUND THEN
						INSERT INTO fnd_sessions(SESSION_ID,EFFECTIVE_DATE)
							values(l_session_id,l_calculated_date);
					ELSIF l_sess_date <> l_calculated_date then
					   update fnd_sessions set effective_date = l_calculated_date
					   where session_id = l_session_id;
					end if;
					close get_sess_date;
						ghr_history_fetch.fetch_peopleei(p_person_id        => l_person_id,
						 p_information_type => 'GHR_US_PER_BENEFIT_INFO',
						 p_date_effective   => l_calculated_date,
						 p_per_ei_data      => l_peopleei_data);

					open c_peopleei_getovn( l_peopleei_data.person_extra_info_id );
					Fetch c_peopleei_getovn into l_peopleei_data.object_version_number;
					close  c_peopleei_getovn;

					IF  fnd_date.canonical_to_date(l_peopleei_data.pei_information14) >  l_agency_effective_date THEN
						IF l_agency_effective_date < l_effective_start_date THEN
							IF fnd_date.canonical_to_date(l_peopleei_data.pei_information14) > l_effective_start_date THEN
								l_peopleei_data.pei_information14 :=  fnd_date.date_to_canonical(l_effective_start_date);
								l_cotrib_update_flag:=1;
							ELSE
								l_cotrib_update_flag:=0;
							END IF;
						ELSE
							l_peopleei_data.pei_information14 :=  fnd_date.date_to_canonical(l_agency_effective_date);
							l_cotrib_update_flag:=1;
						END IF;
						IF l_cotrib_update_flag = 1 THEN
							l_cotrib_update_flag:=0;
						      pe_pei_upd.upd(
						      p_person_extra_info_id     => l_peopleei_data.person_extra_info_id     ,
						      p_request_id               => l_peopleei_data.request_id               ,
						      p_program_application_id   => l_peopleei_data.program_application_id   ,
						      p_program_id               => l_peopleei_data.program_id               ,
						      p_program_update_date      => l_peopleei_data.program_update_date      ,
						      p_pei_attribute_category   => l_peopleei_data.pei_attribute_category   ,
						      p_pei_attribute1           => l_peopleei_data.pei_attribute1           ,
						      p_pei_attribute2           => l_peopleei_data.pei_attribute2           ,
						      p_pei_attribute3           => l_peopleei_data.pei_attribute3           ,
						      p_pei_attribute4           => l_peopleei_data.pei_attribute4           ,
						      p_pei_attribute5           => l_peopleei_data.pei_attribute5           ,
						      p_pei_attribute6           => l_peopleei_data.pei_attribute6           ,
						      p_pei_attribute7           => l_peopleei_data.pei_attribute7           ,
						      p_pei_attribute8           => l_peopleei_data.pei_attribute8           ,
						      p_pei_attribute9           => l_peopleei_data.pei_attribute9           ,
						      p_pei_attribute10          => l_peopleei_data.pei_attribute10          ,
						      p_pei_attribute11          => l_peopleei_data.pei_attribute11          ,
						      p_pei_attribute12          => l_peopleei_data.pei_attribute12          ,
						      p_pei_attribute13          => l_peopleei_data.pei_attribute13          ,
						      p_pei_attribute14          => l_peopleei_data.pei_attribute14          ,
						      p_pei_attribute15          => l_peopleei_data.pei_attribute15          ,
						      p_pei_attribute16          => l_peopleei_data.pei_attribute16          ,
						      p_pei_attribute17          => l_peopleei_data.pei_attribute17          ,
						      p_pei_attribute18          => l_peopleei_data.pei_attribute18          ,
						      p_pei_attribute19          => l_peopleei_data.pei_attribute19          ,
						      p_pei_attribute20          => l_peopleei_data.pei_attribute20          ,
						      p_pei_information_category => l_peopleei_data.pei_information_category ,
						      p_pei_information1         => l_peopleei_data.pei_information1         ,
						      p_pei_information2         => l_peopleei_data.pei_information2         ,
						      p_pei_information3         => l_peopleei_data.pei_information3         ,
						      p_pei_information4         => l_peopleei_data.pei_information4         ,
						      p_pei_information5         => l_peopleei_data.pei_information5         ,
						      p_pei_information6         => l_peopleei_data.pei_information6         ,
						      p_pei_information7         => l_peopleei_data.pei_information7         ,
						      p_pei_information8         => l_peopleei_data.pei_information8         ,
						      p_pei_information9         => l_peopleei_data.pei_information9         ,
						      p_pei_information10        => l_peopleei_data.pei_information10        ,
						      p_pei_information11        => l_peopleei_data.pei_information11        ,
						      p_pei_information12        => l_peopleei_data.pei_information12        ,
						      p_pei_information13        => l_peopleei_data.pei_information13        ,
						      p_pei_information14        => l_peopleei_data.pei_information14        ,
						      p_pei_information15        => l_peopleei_data.pei_information15        ,
						      p_pei_information16        => l_peopleei_data.pei_information16        ,
						      p_pei_information17        => l_peopleei_data.pei_information17        ,
						      p_pei_information18        => l_peopleei_data.pei_information18        ,
						      p_pei_information19        => l_peopleei_data.pei_information19        ,
						      p_pei_information20        => l_peopleei_data.pei_information20        ,
						      p_pei_information21        => l_peopleei_data.pei_information21        ,
						      p_pei_information22        => l_peopleei_data.pei_information22        ,
						      p_pei_information23        => l_peopleei_data.pei_information23        ,
						      p_pei_information24        => l_peopleei_data.pei_information24        ,
						      p_pei_information25        => l_peopleei_data.pei_information25        ,
						      p_pei_information26        => l_peopleei_data.pei_information26        ,
						      p_pei_information27        => l_peopleei_data.pei_information27        ,
						      p_pei_information28        => l_peopleei_data.pei_information28        ,
						      p_pei_information29        => l_peopleei_data.pei_information29        ,
						      p_pei_information30        => l_peopleei_data.pei_information30        ,
						      p_object_version_number    => l_peopleei_data.object_version_number
							);



							ghr_api.g_api_dml	:= TRUE;
							ghr_history_api.post_update_process;
							ghr_history_api.reinit_g_session_var;
							ghr_api.g_api_dml	:= FALSE;

							IF (l_agency_effective_date <= fnd_date.canonical_to_date(l_agncy_contrib_elig_date)
								AND  fnd_date.canonical_to_date(l_agncy_contrib_elig_date)  < SYSDATE)
								AND l_process_log_upd_flag = 0 THEN
								l_tsp_abv_agcy_rec_cnt := l_tsp_abv_agcy_rec_cnt+1;
								FOR l_get_tsp_date IN c_get_tsp_date LOOP
									l_tsp_start_date := l_get_tsp_date.screen_entry_value;
									EXIT;
								END LOOP;
								ghr_wgi_pkg.create_ghr_errorlog(
											p_program_name => l_program_name,
											p_message_name => 'Upgrade for TSP-Warning',
											p_log_text     => 'Warning : Please verify the TSP Status Start Date ' ||
											' For Person Name ' || l_employee_name ||
											' SSN ' || l_employee_number ||
											' system date ' || to_char(sysdate,'DD-MON-RRRR') ||
											' TSP Agency Contrib Elig Date ' || l_calculated_date ||
											' TSP status ' || l_screen_entry_value ||
											' TSP status start Date ' || l_tsp_start_date ||
											' Agency Effective Date ' || l_agency_effective_date,
											p_log_date     => sysdate);

							ELSE
								l_process_log_upd_flag:=0;
							END IF;
						END IF;--IF l_cotrib_update_flag = 1
					END IF;--IF  fnd_date.canonical_to_date(l_peopleei_data.pei_information14)
					Exception
					  When Others then
					       ghr_wgi_pkg.create_ghr_errorlog(
							p_program_name => l_program_name,
							p_message_name => 'B.Person for TSP-ERROR',
							p_log_text     => 'Error : Upgrade of TSP Person EIT  Error ' ||
							' For SSN ' || l_employee_number ||
							' Element ' || to_char(l_element_entry_id) ||
							' Assignment ' || to_char(l_assignment_id) ||
							' SQLERR ' || SQLERRM,
							p_log_date     => sysdate);

							ghr_history_api.reinit_g_session_var;
							ghr_api.g_api_dml	:= FALSE;

				END;--B4
			END IF;--l_retirement_plan IN('K','L', 'M
		   END IF;--IF  fnd_date.canonical_to_date(l_agncy_contrib_elig_date) >
		END LOOP;--for l_tsp_agncy_date
		BEGIN --B4
			if l_tsp_abv_agcy_rec_cnt <> 0 then

				ghr_wgi_pkg.create_ghr_errorlog(
					p_program_name => l_program_name,
					p_message_name => 'Upgrade Script for TSP',
					p_log_text     => 'TSP Data Modified successfully....'
					|| to_char(l_tsp_abv_agcy_rec_cnt) || ' rows',
					p_log_date     => sysdate);
			else
				ghr_wgi_pkg.create_ghr_errorlog(
					p_program_name => l_program_name,
					p_message_name => 'Upgrade Script for TSP',
					p_log_text     => 'TSP Data Not required to modify...',
					p_log_date     => sysdate);
			end if;
			commit;
		END; --B4
	END; --B1
	--Begin  Future Actions TSP update
	BEGIN --C1
		l_tsp_future_rec_cnt :=0;
		for l_future_actions in c_future_actions LOOP

			l_pa_request_id :=  l_future_actions.pa_request_id;
			l_rpa_agncy_contrib_elig_date	:=  l_future_actions.rei_information17;
			l_rpa_effective_date		:=  l_future_actions.effective_date;
			l_rpa_tsp_status_code		:=  l_future_actions.rei_information15;

			BEGIN --C2
				l_update_flag      := 0;
				l_elig_date_flag   := 0;
				IF l_rpa_tsp_status_code = ('I') THEN
					l_update_flag        := 1;
					l_rpa_tsp_status_code := 'E';
				ELSIF l_rpa_tsp_status_code = ('W') THEN
					l_update_flag        := 1;
					l_rpa_tsp_status_code := 'Y';
				ELSIF l_rpa_tsp_status_code = ('S') THEN
					l_update_flag        := 1;
					l_rpa_tsp_status_code := 'T';
				END IF;
				IF l_rpa_agncy_contrib_elig_date IS NOT NULL AND
					(fnd_date.canonical_to_date(l_rpa_agncy_contrib_elig_date) <> l_rpa_effective_date) THEN
					l_elig_date_flag :=1;
				END IF;
				IF l_update_flag = 1  OR l_elig_date_flag =1 THEN
					l_tsp_future_rec_cnt := l_tsp_future_rec_cnt+1;
					IF  l_update_flag = 1 THEN
						l_update_flag := 0;
						UPDATE  ghr_pa_request_extra_info
						SET	rei_information15 =l_rpa_tsp_status_code
						where	information_type='GHR_US_PAR_BENEFITS'
						AND	pa_request_id = l_pa_request_id;
					END IF;
					IF  l_elig_date_flag = 1 THEN
						l_elig_date_flag:=0;
						UPDATE  ghr_pa_request_extra_info
						SET	rei_information17 = fnd_date.date_to_canonical(l_rpa_effective_date)
						where	information_type='GHR_US_PAR_BENEFITS'
						AND	pa_request_id = l_pa_request_id;
					END IF;
				END IF;
				EXCEPTION
				WHEN OTHERS THEN
				    ghr_wgi_pkg.create_ghr_errorlog(
				    p_program_name => l_program_name,
				    p_message_name => 'TSP Future act ERROR: ',
				    p_log_text     => 'Error : Upgrade of TSP Errored ' ||
						' Pa Request Id ' || to_char(l_pa_request_id) ||
						' TSP Status Code ' || l_rpa_tsp_status_code ||
						' SQLERR ' || SQLERRM,
				    p_log_date     => sysdate);
				commit;

			END;--C2
		END LOOP;
		IF l_tsp_future_rec_cnt <> 0 THEN
			ghr_wgi_pkg.create_ghr_errorlog(
			    p_program_name => l_program_name,
			    p_message_name => 'Update Script for Future TSP',
			    p_log_text     => 'Total Future Action records Modified successfully.... ' || to_char(l_tsp_future_rec_cnt) || ' rows',
			    p_log_date     => sysdate);
		ELSE
			ghr_wgi_pkg.create_ghr_errorlog(
				p_program_name => l_program_name,
				p_message_name => 'Update Script for Future TSP',
				p_log_text     => 'TSP(Future Actions) Data Not required to modify...',
				p_log_date     => sysdate);
		END IF;
	END;--C1
	-- End Future Actions TSP update

END execute_tsp_conversion;
--End Bug# 8622486

END GHR_ELT_TO_BEN_PKG;

/
