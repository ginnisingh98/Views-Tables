--------------------------------------------------------
--  DDL for Package Body PAY_GB_EYCTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EYCTL" AS
/* $Header: payeyctl.pkb 115.2 99/10/07 04:08:05 porting ship  $ */
/* Copyright (c) Oracle Corporation 1995. All rights reserved

  Name          : PAYEYCTL
  Description   : End of year control process
  Author        : P.Driver
  Date Created  : 17/11/95

 Change List
 -----------
 Date      Name            Vers     Bug No     Description
 +---------+---------------+--------+----------+-------------------------+
 23/11/95  P.Driver                            Fix bugs in P60 call and
                                               mag tape parameters. The
                                               call to mag tape proc
                                               altered.
 05/12/95  P.Driver                            Only call P60 if no
                                               process has failed.
 24/04/96  T.Inekuku                           Added and set failure
                                               variable to true if error
                                               with extract, also added
                                               return to terminate.
 14/06/96  C.Barbieri                          The current version do not
                                               delete any data in the DB.
                                               Now the EOY Process is
                                               aborted if one of the child
                                               process has an error.
 30/07/96  J.Alloun                            Added error handling.
 05/08/96  aswong			       Added exit at the end.
 07/10/99  P Davies                            Changed each occurrence of
                                               DBMS_Output.Put_Line with
                                               hr_utility.trace.
*/


PROCEDURE eoy_control(	ERRBUF              OUT VARCHAR2
			,RETCODE             OUT NUMBER
			,p_permit_no         IN VARCHAR2
			,p_tax_year          IN NUMBER
			,p_eoy_mode          IN VARCHAR2
			,p_business_group_id IN NUMBER
			,p_tax_dist_ref      IN VARCHAR2
			,p_sort_order1       IN VARCHAR2
			,p_sort_order2       IN VARCHAR2
			,p_sort_order3       IN VARCHAR2
			,p_sort_order4       IN VARCHAR2
			,p_sort_order5       IN VARCHAR2
			,p_sort_order6       IN VARCHAR2
			,p_sort_order7       IN VARCHAR2
			,p_align             IN VARCHAR2
			,p_ni_y_flag         In VARCHAR2) IS
--
-- This procedure controls the execution of the EOY process.
-- The extract is called first followed by the mag tape process,
-- the p35 listing and, only if the full eoy mode is set, the p60
-- report is run last.
--
l_extract_id   NUMBER;
l_ass_id       NUMBER;
l_mag_id       NUMBER;
l_p35_id       NUMBER;
l_p60_id       NUMBER;
l_session_date DATE;
l_session_char VARCHAR2(11);
l_wait_outcome BOOLEAN;
l_phase        VARCHAR2(80);
l_status       VARCHAR2(80);
l_dev_phase    VARCHAR2(80);
l_dev_status   VARCHAR2(80);
l_message      VARCHAR2(80);
l_request_id   VARCHAR2(80);
l_file_name    VARCHAR2(80);
l_errbuf       VARCHAR2(1000);
l_retcode      NUMBER(2);

--
PROG_FAILURE   CONSTANT NUMBER := 2 ;
PROG_SUCCESS   CONSTANT NUMBER := 0 ;
--
BEGIN

  hr_utility.trace('Start EOY_CONTROL in PAYEYCTL.pkb');
  l_session_date := TRUNC(SYSDATE);
  l_session_char := TO_CHAR(TRUNC(SYSDATE),'DD-MON-YYYY');
  l_request_id   := fnd_profile.value('CONC_REQUEST_ID');
------------------------------
-- Call EOY EXTRACT PROCESS --
------------------------------
  hr_utility.trace('Start EXTRACT PROCESS');
  pay_year_end_extract.extract(
				p_permit_no,
				p_business_group_id,
				p_tax_dist_ref,
				p_tax_year,
				l_request_id,
				p_ni_y_flag,
				l_retcode,
				l_errbuf);
--
  hr_utility.trace('Finished EXTRACT PROCESS');
  hr_utility.trace('');
--
  IF l_retcode = 0 THEN
    errbuf := l_errbuf;
    hr_utility.trace('EXTRACT returned failure message: see '||l_errbuf);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return;
  END IF;
-------------------------------------
-- Call MULTIPLE ASSIGNMENT REPORT --
-------------------------------------
  hr_utility.trace('');
  hr_utility.trace('Start MULTIPLE ASSIGNMENT REPORT');
  l_ass_id := fnd_request.submit_request(
					application => 'PAY',
					program     => 'PAYYEMAR',
					argument1   => l_request_id);
  l_file_name := 'l' || TO_CHAR(l_ass_id) || '.req';
  IF l_ass_id = 0 THEN
    errbuf  := 'Error calling the multiple assignments report ';
    hr_utility.trace('MULTIPLE ASSIGNMENT REPORT returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return ;
  END IF;
  -- Now commit request
  COMMIT;
  hr_utility.trace('    Submitted Req id: ' || TO_CHAR(l_ass_id) );
  l_wait_outcome := fnd_concurrent.wait_for_request(
			   request_id => l_ass_id,
			   interval   => 5,
			   phase      => l_phase,
			   status     => l_status,
			   dev_phase  => l_dev_phase,
			   dev_status => l_dev_status,
			   message    => l_message);

  hr_utility.trace('    Status : '||l_dev_status);
  hr_utility.trace('    Phase  : '||l_dev_phase);
  IF l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL' THEN
    errbuf  := 'Error in the multiple assignments report ';
    hr_utility.trace('MULTIPLE ASSIGNMENT REPORT returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return;
  END IF;
  hr_utility.trace('Finished MULTIPLE ASSIGNMENT REPORT');
---------------------------
-- Call MAG TAPE PROCESS --
---------------------------
  hr_utility.trace('');
  hr_utility.trace('Start MAG TAPE PROCESS');
  l_mag_id := fnd_request.submit_request(
			application => 'PAY',
			program     => 'PYUMAG',
			argument1  => 'pay_gb_eoy.eoy',
			argument2  =>  NULL,
			argument3  =>  NULL,
			argument4  =>  l_session_char,
			argument5  =>  'PERMIT='||p_permit_no,
			argument6  =>  'EOY_MODE='||p_eoy_mode,
			argument7  =>  'TAX_DISTRICT_REFERENCE='
					||p_tax_dist_ref,
			argument8  =>  'BUSINESS_GROUP_ID='
					||p_business_group_id);

  l_file_name := 'l' || TO_CHAR(l_mag_id) || '.req';
  IF l_mag_id = 0 THEN
    errbuf  := 'Error calling the mag tape process';
    hr_utility.trace('MAG TAPE PROCESS returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return ;
  END IF;
  COMMIT;
  hr_utility.trace('    Submitted Req id: ' || TO_CHAR(l_mag_id) );
  l_wait_outcome := fnd_concurrent.wait_for_request(
			   request_id => l_mag_id,
			   interval   => 5,
			   phase      => l_phase,
			   status     => l_status,
			   dev_phase  => l_dev_phase,
			   dev_status => l_dev_status,
			   message    => l_message);

  hr_utility.trace('    Status : '||l_dev_status);
  hr_utility.trace('    Phase  : '||l_dev_phase);
  IF l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL' THEN
    errbuf  := 'Error in the mag tape process';
    hr_utility.trace('MAG TAPE PROCESS returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return;
  END IF;
  hr_utility.trace('Finished MAG TAPE PROCESS');
----------------------
-- Call P35 PROCESS --
----------------------
  hr_utility.trace('');
  hr_utility.trace('Start P35 REPORT');
  l_p35_id := fnd_request.submit_request(
			   application       => 'PAY',
			   program           => 'PAYRPP35',
		           argument1         => l_mag_id,
		           argument2         => p_permit_no,
			   argument3         => p_tax_dist_ref,
			   argument4         => p_business_group_id);
  -- Check the result of the p35 call
  l_file_name := 'l' || TO_CHAR(l_p35_id) || '.req';
  IF l_p35_id = 0 THEN
    errbuf  := 'Error calling the P35 report';
    hr_utility.trace('P35 REPORT returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return ;
  END IF;
  COMMIT;
  hr_utility.trace('    Submitted Req id: ' || TO_CHAR(l_p35_id) );
  l_wait_outcome := fnd_concurrent.wait_for_request(
			   request_id => l_p35_id,
			   phase      => l_phase,
			   status     => l_status,
			   dev_phase  => l_dev_phase,
			   dev_status => l_dev_status,
			   message    => l_message);
  hr_utility.trace('    Status : '||l_dev_status);
  hr_utility.trace('    Phase  : '||l_dev_phase);
  IF l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL' THEN
    errbuf  := 'Error in the P35 report';
    hr_utility.trace('P35 REPORT returned failure message: see ' || l_file_name);
    retcode := PROG_FAILURE ;
    hr_utility.raise_error;
    return;
  END IF;
  hr_utility.trace('Finished P35 REPORT');
----------------------
-- Call P60 PROCESS --
----------------------
  IF p_eoy_mode = 'F' THEN
    hr_utility.trace('');
    hr_utility.trace('Start P60 REPORT');
    IF UPPER(NVL(p_align,'N')) = 'Y' THEN
      l_p60_id := fnd_request.submit_request(
			   application => 'PAY',
			   program     => 'PAYRPP60',
		           argument1  => p_permit_no,
		           argument2  => p_tax_year,
		           argument3  => p_sort_order1,
		           argument4  => p_sort_order2,
		           argument5  => p_sort_order3,
		           argument6  => p_sort_order4,
		           argument7  => p_sort_order5,
		           argument8  => p_sort_order6,
		           argument9  => p_sort_order7,
		           argument10  => p_business_group_id,
		           argument11  => p_align,
			   argument12  => p_tax_dist_ref);
      l_file_name := 'l' || TO_CHAR(l_p60_id) || '.req';
      IF l_p60_id = 0 THEN
	errbuf  := 'Error calling the P60 report';
        hr_utility.trace('P60 REPORT returned failure message: see ' || l_file_name);
        retcode := PROG_FAILURE ;
        hr_utility.raise_error;
        return ;
      END IF;
      COMMIT;
      hr_utility.trace('    Submitted Req id: ' || TO_CHAR(l_p60_id) );
      l_wait_outcome := fnd_concurrent.wait_for_request(
  			   request_id => l_p60_id,
			   phase      => l_phase,
			   status     => l_status,
			   dev_phase  => l_dev_phase,
			   dev_status => l_dev_status,
			   message    => l_message);
      hr_utility.trace('    Status : '||l_dev_status);
      hr_utility.trace('    Phase  : '||l_dev_phase);
      IF l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL' THEN
	errbuf  := 'Error in the P60 report';
        hr_utility.trace('P60 REPORT returned failure message: see ' || l_file_name);
        retcode := PROG_FAILURE ;
        hr_utility.raise_error;
	return;
      END IF;
      hr_utility.trace('Finished P60 REPORT');
    END IF;
----------------------
-- Call P60 PROCESS --
----------------------
    hr_utility.trace('');
    hr_utility.trace('Start P60 REPORT');
    l_p60_id := fnd_request.submit_request(
			   application => 'PAY',
			   program     => 'PAYRPP60',
		           argument1  => p_permit_no,
		           argument2  => p_tax_year,
		           argument3  => p_sort_order1,
		           argument4  => p_sort_order2,
		           argument5  => p_sort_order3,
		           argument6  => p_sort_order4,
		           argument7  => p_sort_order5,
		           argument8  => p_sort_order6,
		           argument9  => p_sort_order7,
		           argument10  => p_business_group_id,
		           argument11  => 'N',
			   argument12  => p_tax_dist_ref);
  -- Check the result of the extract call
    l_file_name := 'l' || TO_CHAR(l_p60_id) || '.req';
    IF l_p60_id = 0 THEN
	errbuf  := 'Error calling the P60 report';
        hr_utility.trace('P60 REPORT returned failure message: see '|| l_file_name);
        retcode := PROG_FAILURE ;
        hr_utility.raise_error;
        return ;
    END IF;
    COMMIT;
    hr_utility.trace('    Submitted Req id: ' || TO_CHAR(l_p60_id) );
    l_wait_outcome := fnd_concurrent.wait_for_request(
			   request_id => l_p60_id,
			   phase      => l_phase,
			   status     => l_status,
			   dev_phase  => l_dev_phase,
			   dev_status => l_dev_status,
			   message    => l_message);
    hr_utility.trace('    Status : '||l_dev_status);
    hr_utility.trace('    Phase  : '||l_dev_phase);
    IF l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL' THEN
	errbuf  := 'Error in the P60 report';
        hr_utility.trace('P60 REPORT returned failure message: see ' || l_file_name);
      retcode := PROG_FAILURE ;
      hr_utility.raise_error;
      return;
    END IF;
    hr_utility.trace('Finished P60 REPORT');
  END IF;
  hr_utility.trace('Finished EOY_CONTROL');
END;
END;/* End of package */

/
