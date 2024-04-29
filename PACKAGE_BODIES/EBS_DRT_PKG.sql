--------------------------------------------------------
--  DDL for Package Body EBS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EBS_DRT_PKG" AS
/* $Header: ebdrtpkg.pkb 120.0.12010000.18 2019/11/06 15:41:32 ktithy noship $ */

  l_package varchar2(33) DEFAULT 'EBS_DRT_PKG.';

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

PROCEDURE merge_results
  (result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type,
  cus_result_tbl  IN per_drt_pkg.result_tbl_type) IS
  n number(15);
BEGIN
  n := result_tbl.count;

	for i in 1..cus_result_tbl.count
	loop

  result_tbl (n+i).person_id := cus_result_tbl(i).person_id;

  result_tbl (n+i).entity_type := cus_result_tbl(i).entity_type;

  result_tbl (n+i).status := cus_result_tbl(i).status;

  result_tbl (n+i).msgcode := cus_result_tbl(i).msgcode;

  result_tbl (n+i).msgaplid := cus_result_tbl(i).msgaplid;
	end loop;

END merge_results;

PROCEDURE ebs_hr_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_hr_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ont_drt_pkg.ont_hr_pre(person_id);
  ben_drt_pkg.ben_hr_pre(person_id);

  PA_DRT_PKG.PA_HR_PRE(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_hr_pre;




PROCEDURE ebs_tca_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_tca_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  HZ_DRT_PKG.tca_tca_pre(person_id);
  oks_drt_pkg.oks_tca_pre(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_tca_pre;



PROCEDURE ebs_fnd_pre
    (person_id       IN         number) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_fnd_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ont_drt_pkg.ont_fnd_pre(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_fnd_pre;


PROCEDURE ebs_drt_pre
  (person_id   IN         number
  ,entity_type IN         varchar2) IS
  l_proc varchar2(72);
  p_person_id number(15);
BEGIN
  l_proc := l_package|| 'ebs_drt_pre';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  IF entity_type = 'HR' THEN
    ebs_hr_pre
                (person_id  => person_id);

    custom_drt_pkg.cus_hr_pre
                (person_id  => person_id);
  ELSIF entity_type = 'TCA' THEN
    ebs_tca_pre
                 (person_id  => person_id);

    custom_drt_pkg.cus_tca_pre
                 (person_id  => person_id);
  ELSIF entity_type = 'FND' THEN
    ebs_fnd_pre
                 (person_id  => person_id);
    custom_drt_pkg.cus_fnd_pre
                 (person_id  => person_id);
  END IF;

  write_log ('Leaving:'|| l_proc,'999');
END ebs_drt_pre;



PROCEDURE ebs_hr_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72) := l_package || 'ebs_hr_drc';
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_hr_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

 BEGIN
  per_drt_pkg.per_hr_drc (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'per_drt_pkg.per_hr_drc Errored');
	END;

	BEGIN
  ghr_drt_pkg.ghr_hr_drc (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ghr_drt_pkg.ghr_hr_drc Errored');
	END;

	BEGIN
  irc_drt_pkg.irc_hr_drc (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'irc_drt_pkg.irc_hr_drc Errored');
	END;

  BEGIN
  ame_drt_pkg.ame_hr_drc (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ame_drt_pkg.ame_hr_drc Errored');
	END;

BEGIN
EAM_DRT_PKG.EAM_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EAM_DRT_PKG.EAM_HR_DRC Errored');
END;

BEGIN
ICX_DRT_PKG.ICX_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;

EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ICX_DRT_PKG.ICX_HR_DRC Errored');
END;

BEGIN
POS_DRT_PKG.POS_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);
  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'POS_DRT_PKG.POS_HR_DRC Errored');
END;

BEGIN
CSI_DRT_PKG.CSI_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CSI_DRT_PKG.CSI_HR_DRC Errored');
END;

BEGIN
OKS_DRT_PKG.OKS_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'OKS_DRT_PKG.OKS_HR_DRC Errored');
END;

BEGIN
OKE_DRT_PKG.OKE_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'OKE_DRT_PKG.OKE_HR_DRC Errored');
END;

BEGIN
IEM_DRT_PKG.IEM_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'IEM_DRT_PKG.IEM_HR_DRC Errored');
END;

BEGIN
PA_DRT_PKG.PA_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PA_DRT_PKG.PA_HR_DRC Errored');
END;

BEGIN
EDR_DRT_PKG.EDR_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EDR_DRT_PKG.EDR_HR_DRC Errored');
END;

BEGIN
PO_DRT_PKG.PO_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PO_DRT_PKG.PO_HR_DRC Errored');
END;

BEGIN
CS_DRT_PKG.CS_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CS_DRT_PKG.CS_HR_DRC Errored');
END;

BEGIN
PAY_EMEA_DRT_PKG.PAY_EMEA_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PAY_EMEA_DRT_PKG.PAY_EMEA_HR_DRC Errored');
END;

BEGIN
okc_drt_pkg.okc_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'okc_drt_pkg.okc_hr_drc Errored');
END;

BEGIN
PAY_MX_DRT.PAY_MX_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
     EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PAY_MX_DRT.PAY_MX_HR_DRC Errored');
END;

BEGIN
PAY_US_DRT.PAY_US_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PAY_US_DRT.PAY_US_HR_DRC Errored');
END;

BEGIN
PAY_CA_DRT.PAY_CA_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PAY_CA_DRT.PAY_CA_HR_DRC Errored');
END;

BEGIN
ENG_DRT_PKG.ENG_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
     EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ENG_DRT_PKG.ENG_HR_DRC Errored');
END;

BEGIN
INV_DRT_PKG.INV_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'INV_DRT_PKG.INV_HR_DRC Errored');
END;

BEGIN
PON_DRT_PKG.PON_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PON_DRT_PKG.PON_HR_DRC Errored');
END;

BEGIN
WIP_DRT_PKG.WIP_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WIP_DRT_PKG.WIP_HR_DRC Errored');
END;

BEGIN
PSP_DRT_PKG.PSP_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PSP_DRT_PKG.PSP_HR_DRC Errored');
END;

BEGIN
PAY_APAC_DRT_PKG.PAY_APAC_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PAY_APAC_DRT_PKG.PAY_APAC_HR_DRC Errored');
END;

BEGIN
PER_WPM_DRT_PKG.PER_WPM_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PER_WPM_DRT_PKG.PER_WPM_HR_DRC Errored');
END;

BEGIN
HXC_DRT_PKG.HXC_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'HXC_DRT_PKG.HXC_HR_DRC Errored');
END;

BEGIN
PN_DRT_PKG.pn_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PN_DRT_PKG.pn_hr_drc Errored');
END;

BEGIN
ont_drt_pkg.ont_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ont_drt_pkg.ont_hr_drc Errored');
END;

BEGIN
cn_drt_pkg.cn_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'cn_drt_pkg.cn_hr_drc Errored');
END;

BEGIN
ar_drt_pkg.ar_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ar_drt_pkg.ar_hr_drc Errored');
END;

BEGIN
ocm_drt_pkg.ocm_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ocm_drt_pkg.ocm_hr_drc Errored');
END;

BEGIN
ben_drt_pkg.ben_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;

      EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ben_drt_pkg.ben_hr_drc Errored');
END;

BEGIN
WF_DRT_PKG.WF_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WF_DRT_PKG.WF_HR_DRC Errored');
END;

 BEGIN
  RCV_DRT_PKG.RCV_HR_DRC (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'RCV_DRT_PKG.RCV_HR_DRC Errored');
  END;

 BEGIN
  IBE_DRT_PKG.IBE_HR_DRC (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'IBE_DRT_PKG.IBE_HR_DRC Errored');
  END;

BEGIN
CSD_DRT_PKG.CSD_HR_DRC(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CSD_DRT_PKG.CSD_HR_DRC Errored');
END;


BEGIN
cac_drt_pkg.cac_hr_drc(p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'cac_drt_pkg.cac_hr_drc Errored');
END;

BEGIN
  ap_web_drt_pkg.oie_hr_drc (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ap_web_drt_pkg.oie_hr_drc Errored');
END;

BEGIN
  AHL_DRT_PKG.AHL_HR_DRC (p_person_id
                         ,ebs_hr_process_tbl);

  FOR drt IN 1 .. ebs_hr_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_hr_process_tbl (drt).person_id
                    ,entity_type => ebs_hr_process_tbl (drt).entity_type
                    ,status      => ebs_hr_process_tbl (drt).status
                    ,msgcode     => ebs_hr_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_hr_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'AHL_DRT_PKG.AHL_HR_DRC Errored');
END;

  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END ebs_hr_drc;

PROCEDURE ebs_tca_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_tca_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  l_proc := l_package|| 'ebs_tca_drc';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');
BEGIN
  per_drt_pkg.per_tca_drc (p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'per_drt_pkg.per_tca_drc Errored');
END;

BEGIN
  irc_drt_pkg.irc_tca_drc (p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'irc_drt_pkg.irc_tca_drc Errored');
END;

BEGIN
  ame_drt_pkg.ame_tca_drc (p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ame_drt_pkg.ame_tca_drc Errored');
END;

BEGIN
ICX_DRT_PKG.ICX_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ICX_DRT_PKG.ICX_TCA_DRC Errored');
END;

BEGIN
OKL_DRT_PKG.OKL_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'OKL_DRT_PKG.OKL_TCA_DRC Errored');
END;

BEGIN
POS_DRT_PKG.POS_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'POS_DRT_PKG.POS_TCA_DRC Errored');
END;

BEGIN
CSI_DRT_PKG.CSI_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
   EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CSI_DRT_PKG.CSI_TCA_DRC Errored');
END;

BEGIN
OKS_DRT_PKG.OKS_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'OKS_DRT_PKG.OKS_TCA_DRC Errored');
END;

BEGIN
IEM_DRT_PKG.IEM_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'IEM_DRT_PKG.IEM_TCA_DRC Errored');
END;

BEGIN
PA_DRT_PKG.PA_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PA_DRT_PKG.PA_TCA_DRC Errored');
END;

BEGIN
PO_DRT_PKG.PO_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PO_DRT_PKG.PO_TCA_DRC Errored');
END;

BEGIN
CS_DRT_PKG.CS_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
      EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CS_DRT_PKG.CS_TCA_DRC Errored');
END;

BEGIN
okc_drt_pkg.okc_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'okc_drt_pkg.okc_tca_drc Errored');
END;

BEGIN
ENG_DRT_PKG.ENG_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ENG_DRT_PKG.ENG_TCA_DRC Errored');
END;

BEGIN
INV_MGD_MVT_DRT_PKG.gbl_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'INV_MGD_MVT_DRT_PKG.gbl_tca_drc Errored');
END;

BEGIN
OZF_DRT_PKG.ozf_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'OZF_DRT_PKG.ozf_tca_drc Errored');
END;

BEGIN
INV_DRT_PKG.INV_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'INV_DRT_PKG.INV_TCA_DRC Errored');
END;

BEGIN
PON_DRT_PKG.PON_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
    EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PON_DRT_PKG.PON_TCA_DRC Errored');
END;

BEGIN
EGO_DRT_PKG.EGO_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
     EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EGO_DRT_PKG.EGO_TCA_DRC Errored');
END;

BEGIN
RLM_DRT_PKG.RLM_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
       EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'RLM_DRT_PKG.RLM_TCA_DRC Errored');
END;

BEGIN
PN_DRT_PKG.pn_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
        EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PN_DRT_PKG.pn_tca_drc Errored');
END;

BEGIN
ont_drt_pkg.ont_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
          EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ont_drt_pkg.ont_tca_drc Errored');
END;

BEGIN
cn_drt_pkg.cn_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
           EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'cn_drt_pkg.cn_tca_drc Errored');
END;

BEGIN
ar_drt_pkg.ar_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ar_drt_pkg.ar_tca_drc Errored');
END;

BEGIN
ocm_drt_pkg.ocm_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ocm_drt_pkg.ocm_tca_drc Errored');
END;

BEGIN
WSH_DRT_PKG.wsh_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WSH_DRT_PKG.wsh_tca_drc Errored');
END;

BEGIN
igi_drt_pkg.igi_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'igi_drt_pkg.igi_tca_drc Errored');
END;

BEGIN
ap_drt_pkg.ap_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ap_drt_pkg.ap_tca_drc Errored');
END;

BEGIN
WF_DRT_PKG.WF_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WF_DRT_PKG.WF_TCA_DRC Errored');
END;

BEGIN
ECX_DRT_PKG.ECX_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ECX_DRT_PKG.ECX_TCA_DRC Errored');
END;

BEGIN
EC_DRT_PKG.EC_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EC_DRT_PKG.EC_TCA_DRC Errored');
END;


 BEGIN
  RCV_DRT_PKG.RCV_TCA_DRC (p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
   when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'RCV_DRT_PKG.RCV_TCA_DRC Errored');
  END;


BEGIN
CSD_DRT_PKG.CSD_TCA_DRC(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'CSD_DRT_PKG.CSD_TCA_DRC Errored');
END;


BEGIN
cac_drt_pkg.cac_tca_drc(p_person_id
                         ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'cac_drt_pkg.cac_tca_drc Errored');
END;

BEGIN
  ap_web_drt_pkg.oie_tca_drc (p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ap_web_drt_pkg.oie_tca_drc Errored');
END;

BEGIN
  AHL_DRT_PKG.AHL_TCA_DRC (p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'AHL_DRT_PKG.AHL_TCA_DRC Errored');
END;


BEGIN
  iby_drt_pkg.iby_tca_drc(p_person_id
                          ,ebs_tca_process_tbl);

  FOR drt IN 1 .. ebs_tca_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_tca_process_tbl (drt).person_id
                    ,entity_type => ebs_tca_process_tbl (drt).entity_type
                    ,status      => ebs_tca_process_tbl (drt).status
                    ,msgcode     => ebs_tca_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_tca_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
         EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'iby_drt_pkg.iby_tca_drc Errored');
END;


  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END ebs_tca_drc;

PROCEDURE ebs_fnd_drc
  (person_id  IN         number
  ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
  ebs_fnd_process_tbl per_drt_pkg.result_tbl_type;
BEGIN
  l_proc := l_package|| 'ebs_fnd_drc';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

BEGIN
  per_drt_pkg.per_fnd_drc (p_person_id
                          ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'per_drt_pkg.per_fnd_drc Errored');
END;

BEGIN
GHR_DRT_PKG.GHR_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'GHR_DRT_PKG.GHR_FND_DRC Errored');
END;

BEGIN
IRC_DRT_PKG.IRC_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'IRC_DRT_PKG.IRC_FND_DRC Errored');
END;

BEGIN
AME_DRT_PKG.AME_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'AME_DRT_PKG.AME_FND_DRC Errored');
END;

BEGIN
EAM_DRT_PKG.EAM_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EAM_DRT_PKG.EAM_FND_DRC Errored');
END;

BEGIN
ICX_DRT_PKG.ICX_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ICX_DRT_PKG.ICX_FND_DRC Errored');
END;

BEGIN
POS_DRT_PKG.POS_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'POS_DRT_PKG.POS_FND_DRC Errored');
END;

BEGIN
CSI_DRT_PKG.CSI_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CSI_DRT_PKG.CSI_FND_DRC Errored');
END;

BEGIN
IEM_DRT_PKG.IEM_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'IEM_DRT_PKG.IEM_FND_DRC Errored');
END;

BEGIN
GMO_DRT_PKG.GMO_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'GMO_DRT_PKG.GMO_FND_DRC Errored');
END;

BEGIN
EDR_DRT_PKG.EDR_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'EDR_DRT_PKG.EDR_FND_DRC Errored');
END;

BEGIN
PO_DRT_PKG.PO_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PO_DRT_PKG.PO_FND_DRC Errored');
END;

BEGIN
CS_DRT_PKG.CS_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'CS_DRT_PKG.CS_FND_DRC Errored');
END;

BEGIN
okc_drt_pkg.okc_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'okc_drt_pkg.okc_fnd_drc Errored');
END;

BEGIN
HZ_DRT_PKG.tca_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'HZ_DRT_PKG.tca_fnd_drc Errored');
END;

BEGIN
PON_DRT_PKG.PON_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'PON_DRT_PKG.PON_FND_DRC Errored');
END;

BEGIN
WIP_DRT_PKG.WIP_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WIP_DRT_PKG.WIP_FND_DRC Errored');
END;

BEGIN
FND_DRT_PKG.fnd_user_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'FND_DRT_PKG.fnd_user_drc Errored');
END;

BEGIN
ont_drt_pkg.ont_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ont_drt_pkg.ont_fnd_drc Errored');
END;

BEGIN
cn_drt_pkg.cn_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'cn_drt_pkg.cn_fnd_drc Errored');
END;

BEGIN
ar_drt_pkg.ar_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ar_drt_pkg.ar_fnd_drc Errored');
END;

BEGIN
ocm_drt_pkg.ocm_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ocm_drt_pkg.ocm_fnd_drc Errored');
END;

BEGIN
WF_DRT_PKG.WF_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'WF_DRT_PKG.WF_FND_DRC Errored');
END;

BEGIN
CSD_DRT_PKG.CSD_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'CSD_DRT_PKG.CSD_FND_DRC Errored');
END;



BEGIN
OKS_DRT_PKG.OKS_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'OKS_DRT_PKG.OKS_FND_DRC Errored');
END;

BEGIN
OZF_DRT_PKG.ozf_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'OZF_DRT_PKG.ozf_fnd_drc Errored');
END;


BEGIN
cac_drt_pkg.cac_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
 EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
  fnd_file.put_line(fnd_file.log, 'cac_drt_pkg.cac_fnd_drc Errored');
END;

BEGIN
ap_web_drt_pkg.oie_fnd_drc(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'ap_web_drt_pkg.oie_fnd_drc Errored');
END;

BEGIN
AHL_DRT_PKG.AHL_FND_DRC(p_person_id
                         ,ebs_fnd_process_tbl);

  FOR drt IN 1 .. ebs_fnd_process_tbl.count LOOP
    add_to_results
                    (person_id   => ebs_fnd_process_tbl (drt).person_id
                    ,entity_type => ebs_fnd_process_tbl (drt).entity_type
                    ,status      => ebs_fnd_process_tbl (drt).status
                    ,msgcode     => ebs_fnd_process_tbl (drt).msgcode
                    ,msgaplid    => ebs_fnd_process_tbl (drt).msgaplid
                    ,result_tbl  => l_process_tbl );
  END LOOP;
  EXCEPTION
  when others then
    fnd_file.put_line(fnd_file.log,'An error was encountered - ' ||SQLERRM);
	fnd_file.put_line(fnd_file.log, 'AHL_DRT_PKG.AHL_FND_DRC Errored');
END;


  result_tbl := l_process_tbl;

  write_log ('Leaving:'|| l_proc,'999');
END ebs_fnd_drc;




PROCEDURE ebs_drt_drc
  (person_id   IN         number
  ,entity_type IN         varchar2
  ,result_tbl  OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  l_proc varchar2(72);
  p_person_id number(15);

  cus_result_tbl per_drt_pkg.result_tbl_type;
BEGIN
  l_proc := l_package|| 'ebs_drt_drc';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  IF entity_type = 'HR' THEN
    ebs_hr_drc
                (person_id  => person_id
                ,result_tbl => result_tbl );
   custom_drt_pkg.cus_hr_drc
                (person_id  => person_id
                ,result_tbl => cus_result_tbl );
  ELSIF entity_type = 'TCA' THEN
    ebs_tca_drc
                 (person_id  => person_id
                 ,result_tbl => result_tbl );

   custom_drt_pkg.cus_tca_drc
                 (person_id  => person_id
                 ,result_tbl => cus_result_tbl );
  ELSIF entity_type = 'FND' THEN
    ebs_fnd_drc
                 (person_id  => person_id
                 ,result_tbl => result_tbl );

   custom_drt_pkg.cus_fnd_drc
                 (person_id  => person_id
                 ,result_tbl => cus_result_tbl );
  END IF;

  merge_results(result_tbl,cus_result_tbl);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_drt_drc;


PROCEDURE ebs_hr_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_hr_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ICX_DRT_PKG.ICX_HR_POST(person_id);
  PO_DRT_PKG.PO_HR_POST(person_id);
  PAY_EMEA_DRT_PKG.pay_emea_hr_post(person_id);
  PAY_MX_DRT.PAY_MX_HR_POST(person_id);
  PAY_US_DRT.PAY_US_HR_POST(person_id);
  PAY_CA_DRT.PAY_CA_HR_POST(person_id);
  PON_DRT_PKG.PON_HR_POST(person_id);
  PAY_APAC_DRT_PKG.PAY_APAC_HR_POST(person_id);
  PER_WPM_DRT_PKG.PER_WPM_HR_POST(person_id);
  HXC_DRT_PKG.HXC_HR_POST(person_id);
  ben_drt_pkg.ben_hr_post(person_id);
  per_drt_pkg.per_hr_post(person_id);
  PAY_DRT.PAY_HR_POST(person_id);

  PA_DRT_PKG.PA_HR_POST(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_hr_post;




PROCEDURE ebs_tca_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_tca_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  ICX_DRT_PKG.ICX_TCA_POST(person_id);
  OKL_DRT_PKG.OKL_TCA_POST(person_id);
  PO_DRT_PKG.PO_TCA_POST(person_id);
  HZ_DRT_PKG.tca_tca_post(person_id);
  WSH_DRT_PKG.wsh_tca_post(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_tca_post;



PROCEDURE ebs_fnd_post
    (person_id       IN         number) IS
  l_proc varchar2(72);
  l_process_tbl per_drt_pkg.result_tbl_type;
  p_person_id number(15);
  n number(15);
BEGIN
  l_proc := l_package|| 'ebs_fnd_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  PO_DRT_PKG.PO_FND_POST(person_id);
  FND_DRT_PKG.fnd_user_post(person_id);

  write_log ('Leaving:'|| l_proc,'999');
END ebs_fnd_post;

PROCEDURE ebs_drt_post
  (person_id   IN         number
  ,entity_type IN         varchar2) IS
  l_proc varchar2(72);
  p_person_id number(15);
BEGIN
  l_proc := l_package|| 'ebs_drt_post';

  write_log ('Entering:'|| l_proc,'10');

  p_person_id := person_id;

  write_log ('p_person_id: '|| p_person_id,'20');

  IF entity_type = 'HR' THEN
    ebs_hr_post
                (person_id  => person_id);
    custom_drt_pkg.cus_hr_post
                (person_id  => person_id);
  ELSIF entity_type = 'TCA' THEN
    ebs_tca_post
                 (person_id  => person_id);
    custom_drt_pkg.cus_tca_post
                 (person_id  => person_id);

  ELSIF entity_type = 'FND' THEN
    ebs_fnd_post
                 (person_id  => person_id);
    custom_drt_pkg.cus_fnd_post
                 (person_id  => person_id);
  END IF;

  write_log ('Leaving:'|| l_proc,'999');
END ebs_drt_post;


  PROCEDURE drt_dependency_checker
    (person_id      IN         varchar2
    ,person_type    IN         varchar2
    ,dependency_tbl OUT NOCOPY dependency_tbl_type) IS
    l_proc varchar2(72);
    l_person_id varchar2(20);
    n number DEFAULT 0;
    l_temp number;
    l_person_type varchar2(3);
    l_party_id varchar2(20);
    l_employee_id varchar2(20);
    CURSOR get_party_persons
      (l_party_id IN varchar2) IS
      SELECT  DISTINCT
              person_id
      FROM    per_all_people_f
      WHERE   party_id = l_party_id
      ORDER BY person_id;
    CURSOR get_dependent_users
      (l_party_id IN varchar2) IS
	  SELECT  user_id
	  FROM    fnd_user
	  WHERE   employee_id IN
	          (
	          SELECT  DISTINCT
	                  person_id
	          FROM    per_all_people_f
	          WHERE   party_id = l_party_id
	          )
	  UNION
	  SELECT  user_id
	  FROM    fnd_user
	  WHERE   employee_id IS NULL
	  AND     person_party_id = l_party_id
	  ORDER BY user_id;
    CURSOR get_person_users
      (l_person_id IN varchar2) IS
      SELECT  user_id
      FROM    fnd_user
      WHERE   employee_id = l_person_id
      ORDER BY user_id;
  BEGIN

      l_proc := l_package
                || 'per_dependency_checker';

      write_log ('Entering:'
                               || l_proc
                              ,'10');


    l_person_id := person_id;

    l_person_type := person_type;

    write_log ('l_person_id: '
                             || l_person_id
                            ,'20');

    write_log ('l_person_type: '
                             || l_person_type
                            ,'20');

    IF l_person_type = 'HR' THEN
      SELECT  DISTINCT
              party_id
      INTO    l_party_id
      FROM    per_all_people_f
      WHERE   person_id = l_person_id;

      IF l_party_id IS NOT NULL THEN
        write_log ('dependent party_id: '
                                 || l_party_id
                                ,'30');

        n := n + 1;

        dependency_tbl (n).person_id := l_party_id;

        dependency_tbl (n).person_type := 'TCA';

        FOR i IN get_party_persons (l_party_id) LOOP
          IF (i.person_id <> l_person_id) THEN
            n := n + 1;

            dependency_tbl (n).person_id := i.person_id;

            dependency_tbl (n).person_type := 'HR';
          END IF;
        END LOOP;

        write_log ('Total no of dependent hr persons: '
                                 || (n - 1)
                                ,'40');

        l_temp := n;

        FOR i IN get_dependent_users (l_party_id) LOOP
          n := n + 1;

          dependency_tbl (n).person_id := i.user_id;

          dependency_tbl (n).person_type := 'FND';
        END LOOP;

        write_log ('Total no of dependent fnd users: '
                                 || (n - l_temp)
                                ,'50');
      ELSE
        FOR i IN get_person_users (l_person_id) LOOP
          n := n + 1;

          dependency_tbl (n).person_id := i.user_id;

          dependency_tbl (n).person_type := 'FND';
        END LOOP;

        write_log ('Total no of dependent fnd users: '
                                 || (n)
                                ,'50');
      END IF;
    ELSIF l_person_type = 'TCA' THEN
      FOR i IN get_party_persons (l_person_id) LOOP
        n := n + 1;

        dependency_tbl (n).person_id := i.person_id;

        dependency_tbl (n).person_type := 'HR';
      END LOOP;

      write_log ('Total no of dependent hr persons: '
                               || (n)
                              ,'60');

      l_temp := n;

      FOR i IN get_dependent_users (l_person_id) LOOP
        n := n + 1;

        dependency_tbl (n).person_id := i.user_id;

        dependency_tbl (n).person_type := 'FND';
      END LOOP;

      write_log ('Total no of dependent fnd users: '
                               || (n - l_temp)
                              ,'70');
    ELSIF l_person_type = 'FND' THEN
      SELECT  employee_id
      INTO    l_employee_id
      FROM    fnd_user
      WHERE   user_id = l_person_id;

      write_log ('dependent person_id: '
                               || l_employee_id
                              ,'80');

      IF l_employee_id IS NOT NULL THEN
        SELECT  DISTINCT
                party_id
        INTO    l_party_id
        FROM    per_all_people_f
        WHERE   person_id = l_employee_id;

        IF l_party_id IS NOT NULL THEN
          write_log ('dependent party_id: '
                                   || l_party_id
                                  ,'80');

          n := n + 1;

          dependency_tbl (n).person_id := l_party_id;

          dependency_tbl (n).person_type := 'TCA';

          FOR i IN get_party_persons (l_party_id) LOOP
            n := n + 1;

            dependency_tbl (n).person_id := i.person_id;

            dependency_tbl (n).person_type := 'HR';
          END LOOP;

          write_log ('Total no of dependent hr persons: '
                                   || (n - 1)
                                  ,'90');

          l_temp := n;

          FOR i IN get_dependent_users (l_party_id) LOOP
            IF (i.user_id <> l_person_id) THEN
              n := n + 1;

              dependency_tbl (n).person_id := i.user_id;

              dependency_tbl (n).person_type := 'FND';
            END IF;
          END LOOP;

          write_log ('Total no of dependent fnd users: '
                                   || (n - l_temp)
                                  ,'100');
        ELSE
          n := n + 1;

          dependency_tbl (n).person_id := l_employee_id;

          dependency_tbl (n).person_type := 'HR';
        END IF;
      ELSE
        write_log ('No hr person or party is attached to this user. So no dependency, Exiting.'
                                ,'80');
      END IF;
    END IF;


      write_log ('Leaving:'
                               || l_proc
                              ,'200');
  EXCEPTION
    WHEN no_data_found THEN
      write_log ('This person_id and person_type combination is invalid.'
                              ,'300');

      write_log ('Leaving:'
                               || l_proc
                              ,'300');
  END drt_dependency_checker;


  PROCEDURE drc_results
    (person_id       IN         number
		,entity_type     IN         varchar2
    ,error    OUT NOCOPY number
		,warning  OUT NOCOPY number
		,results_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) is

		g_dependency_tbl ebs_drt_pkg.g_dependency_tbl%type;
		l_process_tbl 			per_drt_pkg.result_tbl_type;
		n number;

		l_result_tbl per_drt_pkg.result_tbl_type;

		l_error number(10) := 0;
		l_warning number(10) := 0;

	begin

			ebs_drt_pkg.drt_dependency_checker(person_id,entity_type,g_dependency_tbl);
			n := g_dependency_tbl.count+1;
			g_dependency_tbl(n).person_id := person_id;
			g_dependency_tbl(n).person_type := entity_type;
				for i in 1..g_dependency_tbl.count
				loop

							ebs_drt_pkg.ebs_drt_drc(g_dependency_tbl(i).person_id,g_dependency_tbl(i).person_type,l_process_tbl);
							for i in 1..l_process_tbl.count
							loop

										if l_process_tbl(i).status = 'E' then

							        add_to_results
							                        (person_id   => l_process_tbl(i).person_id
							                        ,entity_type => l_process_tbl(i).entity_type
							                        ,status      => l_process_tbl(i).status
							                        ,msgcode     => l_process_tbl(i).msgcode
							                        ,msgaplid    => l_process_tbl(i).msgaplid
							                        ,result_tbl  => l_result_tbl );

											l_error := l_error + 1;
										elsif l_process_tbl(i).status = 'W' then

							        add_to_results
							                        (person_id   => l_process_tbl(i).person_id
							                        ,entity_type => l_process_tbl(i).entity_type
							                        ,status      => l_process_tbl(i).status
							                        ,msgcode     => l_process_tbl(i).msgcode
							                        ,msgaplid    => l_process_tbl(i).msgaplid
							                        ,result_tbl  => l_result_tbl );

											l_warning := l_warning + 1;
										end if;

							end loop;

				end loop;

				error := l_error;
				warning := l_warning;
				results_tbl := l_result_tbl;

	end drc_results;

  PROCEDURE check_drc
    (chk_drc_batch IN  EBS_DRT_REMOVAL_REC
		,request_id OUT NOCOPY number) is

	l_request_id number(15) := 0;
	l_batch_id	number;

	cursor c_batch is select PER_DRT_PERSON_BATCH_S.nextval from dual;

	begin
		/* Create a batch_id */
		open c_batch;
		fetch c_batch into l_batch_id;
		close c_batch;

		/* Insert the table into DB stage table with operation type as CONSTRAINT */
		forall i in 1..chk_drc_batch.count
			insert into PER_DRT_PERSON_BATCH values(l_batch_id,chk_drc_batch(i).person_id,chk_drc_batch(i).person_type,'CONSTRAINT');

		COMMIT;

		/* Submitting Check DRC Concurrent Request */
  l_request_id := fnd_request.submit_request (
                            application   => 'PER',
                            program       => 'CHK_DRC_MAIN',
                            description   => 'Check For Data Removal Constraints',
                            start_time    => sysdate,
                            sub_request   => FALSE,
														argument1  		=> l_batch_id);

		/* Retrun the concurrent request ID */
	request_id := l_request_id;

	end check_drc;

	procedure submit_request(errbuf 		      out NOCOPY varchar2,
                          retcode 		      out NOCOPY number,
													p_batch_id number) is

 l_request_id                number;
 l_effective_date            varchar2(50) := trunc(sysdate);
 l_update_date  date;
 l_debug        boolean := FALSE;
 l_success      boolean;
 l_status       varchar2(100);
 l_phase        varchar2(100);
 l_dev_status   varchar2(100);
 l_dev_phase    varchar2(100);
 l_message      varchar2(100);
 l_request_data varchar2(100);
 c_wait         number := 60;
 c_timeout      number := 300;
 l_call_status boolean;

 l_proc varchar2(60) := l_package||'.submit_request';

CURSOR c_removal_id
  (p_person_id IN number
  ,p_entity_type IN varchar2) IS
  SELECT  removal_id
  FROM    per_drt_person_data_removals
  WHERE   person_id = p_person_id
  AND     entity_type = p_entity_type;


CURSOR c_drc_batch IS
  SELECT  *
  FROM    PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT' and batch_id = p_batch_id;

	l_removal_id number(15);
	l_process_tbl 			per_drt_pkg.result_tbl_type;
	l_error number(10) := 0;
	l_warning number(10) := 0;

begin

	fnd_file.put_line(fnd_file.log, 'Processing Batch :' || p_batch_id);

	/* Loop through the CONSTRAINT batch */
	for drc_person in c_drc_batch
	loop


		/* Get the removal_id for the person_id and entity_type */
							open c_removal_id(drc_person.person_id,drc_person.entity_type);
							fetch c_removal_id into l_removal_id;
							close c_removal_id;

								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: person_id :' || drc_person.person_id );
								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: entity_type :' || drc_person.entity_type );
								fnd_file.put_line(fnd_file.log, 'CONSTRAINT :: Removal ID :' || l_removal_id );

		/* Run the DRC batch for the person and the dependents */
		ebs_drt_pkg.drc_results(drc_person.person_id,drc_person.entity_type,l_error,l_warning,l_process_tbl);

		/* Remove the constraints from the DB table if there are any for the removal_id */
		delete from PER_DRT_PERSON_CONSTRAINTS where removal_id = l_removal_id;

		/* Loop through the constraints and insert to the DB Table */
		forall i in 1..l_process_tbl.count
			insert into PER_DRT_PERSON_CONSTRAINTS
			(CONSTRAINT_ID
			,REMOVAL_ID
			,PERSON_ID
			,ENTITY_TYPE
			,CONSTRAINT_TYPE
			,MESSAGE_NAME
			,MSG_APPLICATION_ID)
			values
			(PER_DRT_PERSON_CONSTRAINTS_s.nextval
			,l_removal_id
			,l_process_tbl(i).person_id
			,l_process_tbl(i).entity_type
			,l_process_tbl(i).status
			,l_process_tbl(i).msgcode
			,l_process_tbl(i).msgaplid);

		/* Count the number of error and warnings, update the counts to the table */
			if l_error > 0 then
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								STATUS = 'Errors Exist'
						where removal_id = l_removal_id;

			elsif l_warning > 0 then
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								STATUS = 'Warnings Exist'
						where removal_id = l_removal_id;

			else
					update PER_DRT_PERSON_DATA_REMOVALS
						set ERROR_COUNT = l_error,
								WARNING_COUNT = l_warning ,
								STATUS = 'No Constraints'
						where removal_id = l_removal_id;

			end if;

	end loop;

	/* Delete from DB stage table with operation type as CONSTRAINT Process done*/
	DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT'  and batch_id = p_batch_id;

  EXCEPTION
    WHEN others THEN
	/* Delete from DB stage table with operation type as CONSTRAINT an error occured*/
			DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'CONSTRAINT'  and batch_id = p_batch_id;

 end submit_request;


procedure run_dml_person(person_id in number
									,entity_type in varchar2
									,process_code out NOCOPY varchar2) is
		x_person_id number(15);
begin

			/* Run the DML for the ID Passed in */
			fnd_file.put_line(fnd_file.log, 'run_dml_person :: Masking ID :' || person_id  ||' TYPE : ' || entity_type);

			BEGIN
				if entity_type = 'HR' then
					fnd_file.put_line(fnd_file.log, 'run_dml_person(REMOVE_HR_PERSON) :: ID :' || person_id  ||' TYPE : ' || entity_type);
					REMOVE_HR_PERSON(person_id);
					process_code := 'S';

				elsif entity_type = 'TCA' then
					fnd_file.put_line(fnd_file.log, 'run_dml_person(REMOVE_TCA_PARTY) :: ID :' || person_id  ||' TYPE : ' || entity_type);
					REMOVE_TCA_PARTY(person_id);
					process_code := 'S';

				elsif entity_type = 'FND' then
					fnd_file.put_line(fnd_file.log, 'run_dml_person(REMOVE_FND_USER) :: ID :' || person_id  ||' TYPE : ' || entity_type);
					REMOVE_FND_USER(person_id);
					process_code := 'S';

				end if;
					fnd_file.put_line(fnd_file.log, 'run_dml_person :: Masked ID :' || person_id  ||' TYPE : ' || entity_type);
				EXCEPTION
					when others then
					fnd_file.put_line(fnd_file.log,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
					fnd_file.put_line(fnd_file.log, 'run_dml_person :: Error ID :' || person_id  ||' TYPE : ' || entity_type);
					process_code := 'E';
					return;
			END;

			/* Run the POST-PROCESS for the passed ID */
			fnd_file.put_line(fnd_file.log, 'run_dml_person(POST-PROCESS) :: POST-PROCESS with ID :' || person_id  ||' TYPE : ' || entity_type);

			BEGIN

				ebs_drt_post(person_id,entity_type);

			EXCEPTION
				when others then

					fnd_file.put_line(fnd_file.log,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
					fnd_file.put_line(fnd_file.log, 'run_dml_person(POST-PROCESS) :: Error ID :' || person_id  ||' TYPE : ' || entity_type);
					process_code := 'E';
					return;

			END;


			/* Add to PER_DRT_HR_PERSON_REMOVED if entity_type is HR */
			BEGIN
				if entity_type = 'HR' then
					x_person_id := person_id;
					fnd_file.put_line(fnd_file.log, 'run_dml_person(PER_DRT_HR_PERSON_REMOVED) :: ID :' || x_person_id  ||' TYPE : ' || entity_type);
					DELETE FROM PER_DRT_HR_PERSON_REMOVED WHERE PERSON_ID = x_person_id;

					INSERT INTO PER_DRT_HR_PERSON_REMOVED(PERSON_ID) VALUES(x_person_id);
					process_code := 'S';
				end if;

			EXCEPTION
				when others then
					fnd_file.put_line(fnd_file.log,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
					fnd_file.put_line(fnd_file.log, 'run_dml_person(PER_DRT_HR_PERSON_REMOVED) :: Error ID :' || person_id  ||' TYPE : ' || entity_type);
					process_code := 'E';
					return;
			END;



end run_dml_person;

procedure run_dml(person_id in number
									,entity_type in varchar2
									,process_code out NOCOPY varchar2) is

		g_dependency_tbl ebs_drt_pkg.g_dependency_tbl%type;
		l_process_code varchar2(1);

begin

			/* Run the DML for the Root ID Passed in */
			fnd_file.put_line(fnd_file.log, 'run_dml :: Masking Root with ID :' || person_id  ||' TYPE : ' || entity_type);
			run_dml_person(person_id => person_id
										,entity_type => entity_type
										,process_code => l_process_code);

			if l_process_code = 'S' then
							fnd_file.put_line(fnd_file.log, 'run_dml :: Masked Root with ID :' || person_id  ||' TYPE : ' || entity_type);
			else
							fnd_file.put_line(fnd_file.log, 'run_dml :: Error Masking Root with ID :' || person_id  ||' TYPE : ' || entity_type);
							return;
			end if;

			/* Get the Dependents for the Root ID Passed in */
			ebs_drt_pkg.drt_dependency_checker(person_id,entity_type,g_dependency_tbl);

				for i in 1..g_dependency_tbl.count
				loop

						/* Run the DML for the Dependents picked for the Root */
						fnd_file.put_line(fnd_file.log, 'run_dml :: Masking Dependent with ID :' || g_dependency_tbl(i).person_id  ||' TYPE : ' || g_dependency_tbl(i).person_type);
						run_dml_person(person_id => g_dependency_tbl(i).person_id
													,entity_type => g_dependency_tbl(i).person_type
													,process_code => l_process_code);

						if l_process_code = 'S' then
										fnd_file.put_line(fnd_file.log, 'run_dml :: Masked Dependent with ID :' || g_dependency_tbl(i).person_id  ||' TYPE : ' || g_dependency_tbl(i).person_type);
										process_code := 'S';
						else
										fnd_file.put_line(fnd_file.log, 'run_dml :: Error Masking Dependent with ID :' || g_dependency_tbl(i).person_id  ||' TYPE : ' || g_dependency_tbl(i).person_type);
										process_code := 'E';
										return;
						end if;

				end loop;
				process_code := 'S';
end run_dml;

procedure process_person(person_id in number
									,entity_type in varchar2
									,process_code out NOCOPY varchar2) is
l_process_code varchar2(1);
	x_removal_id number(15);

CURSOR c_removal_id
  (p_person_id IN number
  ,p_entity_type IN varchar2) IS
  SELECT  removal_id
  FROM    per_drt_person_data_removals
  WHERE   person_id = p_person_id
  AND     entity_type = p_entity_type;

begin

	fnd_file.put_line(fnd_file.log, 'process_person :: Processing with ID :' || person_id  ||' TYPE : ' || entity_type);
							/* Get the REMOVAL_ID for the PERSON */
							open c_removal_id(person_id,entity_type);
							fetch c_removal_id into x_removal_id;
							close c_removal_id;
								fnd_file.put_line(fnd_file.log, 'process_person :: person_id :' || person_id );
								fnd_file.put_line(fnd_file.log, 'process_person :: entity_type :' || entity_type );
								fnd_file.put_line(fnd_file.log, 'process_person :: Removal ID :' || x_removal_id );

	SAVEPOINT process_person_drt;

	/* Run the PRE-PROCESS for the passed ID */
	fnd_file.put_line(fnd_file.log, 'process_person(PRE-PROCESS) :: PRE-PROCESS with ID :' || person_id  ||' TYPE : ' || entity_type);


	BEGIN

		ebs_drt_pre(person_id,entity_type);

	EXCEPTION
	when others then

				ROLLBACK to process_person_drt;
				process_code := 'E';

					/* An Error occured processing the person, log it */
					fnd_file.put_line(fnd_file.log, 'process_person(PRE-PROCESS) :: Error ID :' || person_id  || ' TYPE : ' || entity_type);
					fnd_file.put_line(fnd_file.OUTPUT, 'ID :' || person_id  || ' TYPE : ' || entity_type || ' Errored');
					return;

	END;


	/* Run the DML for the passed ID */
	fnd_file.put_line(fnd_file.log, 'process_person(RUN_DML) :: RUN_DML with ID :' || person_id  ||' TYPE : ' || entity_type);
		run_dml(person_id => person_id
						,entity_type => entity_type
						,process_code => l_process_code);

	process_code := l_process_code;

			/* Validate the process_code if the process error then rollback else commit and update the status  */
			if process_code = 'S' then
					/* Update the person removal record to REMOVED */
								update PER_DRT_PERSON_DATA_REMOVALS
									set STATUS = 'Removed'
									where removal_id = x_removal_id;

					fnd_file.put_line(fnd_file.log, 'process_person :: Processed ID :' || person_id  || ' TYPE : ' || entity_type);
					fnd_file.put_line(fnd_file.OUTPUT, 'ID :' || person_id  || ' TYPE : ' || entity_type || ' Processed Successfully');

				COMMIT;
				process_code := 'S';

			else
				ROLLBACK to process_person_drt;
				--process_code := 'E';

					/* An Error occured processing the person, log it */
					fnd_file.put_line(fnd_file.log, 'process_person :: Error ID :' || person_id  || ' TYPE : ' || entity_type);
					fnd_file.put_line(fnd_file.OUTPUT, 'ID :' || person_id  || ' TYPE : ' || entity_type || ' Errored');

-- Fix For Bug # 30175771
					/* Update the person removal record to Remove Error */
								update PER_DRT_PERSON_DATA_REMOVALS
									set STATUS = 'Remove Error'
									where removal_id = x_removal_id;

					COMMIT;

				process_code := 'E';


			end if;
end process_person;

procedure submit_remove_request(errbuf out NOCOPY varchar2,
																retcode out NOCOPY number,
																p_batch_id number) is

 l_request_id                number;
 l_effective_date            varchar2(50) := trunc(sysdate);
 l_update_date  date;
 l_debug        boolean := FALSE;
 l_success      boolean;
 l_status       varchar2(100);
 l_phase        varchar2(100);
 l_dev_status   varchar2(100);
 l_dev_phase    varchar2(100);
 l_message      varchar2(100);
 l_request_data varchar2(100);
 c_wait         number := 60;
 c_timeout      number := 300;
 l_call_status boolean;

 l_proc varchar2(60) := l_package||'.submit_request';

CURSOR c_remove_batch IS
  SELECT  *
  FROM    PER_DRT_PERSON_BATCH where operation_type = 'REMOVE' and batch_id = p_batch_id;

	l_process_code varchar2(1);

begin

	fnd_file.put_line(fnd_file.log, 'Processing Batch :' || p_batch_id);

	/* Loop through the REMOVE batch */
	for remove_person in c_remove_batch
	loop

		BEGIN

						/* Call the process_person for the PERSON record */
						fnd_file.put_line(fnd_file.log, '     ');
						fnd_file.put_line(fnd_file.log, 'Processing ID :' || remove_person.person_id  || ' TYPE : ' || remove_person.entity_type);
						process_person(person_id => remove_person.person_id
													,entity_type => remove_person.entity_type
													,process_code => l_process_code);

		EXCEPTION
			when others then
				/* An Error occured log it */
				fnd_file.put_line(fnd_file.log,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
				fnd_file.put_line(fnd_file.log,'Error ID :' || remove_person.person_id  || ' TYPE : ' || remove_person.entity_type);
		END;

	end loop;

	/* Delete from DB stage table with operation type as REMOVE */
	DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'REMOVE'  and batch_id = p_batch_id;

  EXCEPTION
    WHEN others THEN
	/* Delete from DB stage table with operation type as REMOVE */
			DELETE FROM PER_DRT_PERSON_BATCH where operation_type = 'REMOVE'  and batch_id = p_batch_id;
end submit_remove_request;


  PROCEDURE drt_remove
    (removal_batch IN  EBS_DRT_REMOVAL_REC
		,request_id OUT NOCOPY number) is

	l_request_id number(15) := 0;
	l_batch_id	number;

	cursor c_batch is select PER_DRT_PERSON_BATCH_S.nextval from dual;

	BEGIN

		/* Create a batch_id */
		open c_batch;
		fetch c_batch into l_batch_id;
		close c_batch;

		/* Insert the table into DB stage table with operation type as REMOVE */
		forall i in 1..removal_batch.count
			insert into PER_DRT_PERSON_BATCH values(l_batch_id,removal_batch(i).person_id,removal_batch(i).person_type,'REMOVE');

		COMMIT;

		/* Submitting Remove DRT Concurrent Request */
  l_request_id := fnd_request.submit_request (
                            application   => 'PER',
                            program       => 'DRT_MAIN_PROGRAM',
                            description   => 'Remove Person Records',
                            start_time    => sysdate,
                            sub_request   => FALSE,
														argument1  		=> l_batch_id);

		/* Retrun the concurrent request ID */
	request_id := l_request_id;

	END drt_remove;


end ebs_drt_pkg;

/
