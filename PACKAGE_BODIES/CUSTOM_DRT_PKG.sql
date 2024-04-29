--------------------------------------------------------
--  DDL for Package Body CUSTOM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUSTOM_DRT_PKG" AS
/* $Header: pecusdrt.pkb 120.0.12010000.1 2018/04/20 07:59:46 jaakhtar noship $ */

  l_package varchar2(33) DEFAULT 'CUSTOM_DRT_PKG.';

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

  result_tbl (n).person_id := person_id;

  result_tbl (n).entity_type := entity_type;

  result_tbl (n).status := status;

  result_tbl (n).msgcode := msgcode;

  result_tbl (n).msgaplid := msgaplid;
END add_to_results;

PROCEDURE cus_hr_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_hr_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_hr_pre;

PROCEDURE cus_tca_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_tca_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_tca_pre;

PROCEDURE cus_fnd_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_fnd_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_fnd_pre;



PROCEDURE cus_hr_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72) := l_package || 'cus_hr_drc';
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_hr_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END cus_hr_drc;

PROCEDURE cus_tca_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72) := l_package || 'cus_tca_drc';
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_hr_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END cus_tca_drc;

PROCEDURE cus_fnd_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72) := l_package || 'cus_fnd_drc';
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_hr_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END cus_fnd_drc;





PROCEDURE cus_hr_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_hr_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_hr_post;

PROCEDURE cus_tca_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_tca_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_tca_post;

PROCEDURE cus_fnd_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'cus_fnd_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ----------------------------------------------------------------------------------
  ---  ***                        ADD YOUR CODE HERE                         *** ---
  ---  *** Call your sub-program (standalone procedure or package procedure) *** ---
  ----------------------------------------------------------------------------------

  write_log ('Leaving:'|| l_proc,'999');
END cus_fnd_post;

end custom_drt_pkg;

/
