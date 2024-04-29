--------------------------------------------------------
--  DDL for Package Body PAY_APAC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_APAC_DRT_PKG" AS
/* $Header: pyapacdrt.pkb 120.0.12010000.7 2018/04/19 07:55:27 dduvvuri noship $*/

l_package          CONSTANT VARCHAR2(50):= 'PAY_APAC_DRT_PKG';
--
--
PROCEDURE write_log
  (message IN varchar2
  ,stage   IN varchar2) IS
BEGIN
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.string (fnd_log.level_procedure
                   ,message
                   ,stage);
  END IF;
END write_log;
--
PROCEDURE add_to_results
	  (person_id   IN            number
	  ,entity_type IN            varchar2
	  ,status      IN            varchar2
	  ,msgcode     IN            varchar2
	  ,msgaplid    IN            number
	  ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS

	  n number(15);

BEGIN
	  n := result_tbl.count + 1;
	  result_tbl(n).person_id := person_id;
	  result_tbl(n).entity_type := entity_type;
	  result_tbl(n).status := status;
	  result_tbl(n).msgcode := msgcode;
         result_tbl(n).msgaplid := msgaplid;
	 -- hr_utility.set_message (msgaplid,msgcode);
	  --result_tbl(n).msgtext := hr_utility.get_message ();
END add_to_results;
--
--
PROCEDURE PAY_APAC_HR_DRC
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72);
    p_person_id varchar2(20);
    l_legislation_code varchar2(20);
	l_success BOOLEAN;
	l_count NUMBER := 0;

BEGIN

    l_proc := l_package|| 'pay_apac_hr_drc';
    write_log ('Entering:'|| l_proc,10);

    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,20);

    l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
    write_log ('l_legislation_code: '|| l_legislation_code, 20);

    l_success:=TRUE;
   /* For all APAC legislations we have taken a decision to not implement Erasure Request
       at the moment. Even if some user want his data to be erased immediately, we are taking a
       safe approach of putting additional 24 months restriction here. This is to give room for
       other pending payable activities if present for that person as per the legislation rules
       which the user may not be aware of. If any users use this Erasure Request functionality
       for APAC legislations - we will then discuss with Product Management and implement it
       as required later in future. But for now - we are bypassing Erasure Request and mandatorily
      putting this 24 months check and raising it as an Error so that data is not removed. */
   IF l_legislation_code IN ('AU','CN','JP','SG','HK','NZ','IN','KR') THEN
	BEGIN

      SELECT  count(*)
      INTO    l_count
      FROM    per_periods_of_service
      WHERE   person_id = p_person_id
      AND     floor(months_between(trunc(sysdate),nvl(final_process_date
                                         ,trunc(sysdate)))) < 24
	  AND rownum = 1;

      IF l_count <> 0 THEN
        add_to_results(person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'HR_500500_EMEA_DRC_REP_PRD'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;

    END;
   END IF;
    write_log ('Leaving:'|| l_proc,999);

END PAY_APAC_HR_DRC;
--

--
PROCEDURE PAY_APAC_HR_POST
  (p_person_id IN number) IS

  l_proc varchar2(72) DEFAULT 'purge_or_mask_post';
  l_person_id number;
  l_legislation_code varchar2(20);

BEGIN

  l_proc := l_package|| l_proc;
  write_log ('Post Processor: '|| l_proc, 10);

	l_person_id := p_person_id;
  write_log ('l_person_id: '|| l_person_id,20);

  l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
  write_log ('l_legislation_code: '|| l_legislation_code, 20);


END PAY_APAC_HR_POST;
--
END PAY_APAC_DRT_PKG;

/
