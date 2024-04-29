--------------------------------------------------------
--  DDL for Package Body PQP_GB_TP_EXT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_TP_EXT_PROCESS" AS
--  /* $Header: pqpgbtpext.pkb 120.0 2005/05/29 02:20:51 appldev noship $ */
--
--

-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE DEBUG (p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
IS

--
BEGIN
--
   pqp_utilities.DEBUG (
      p_trace_message               => p_trace_message
     ,p_trace_location              => p_trace_location
   );
--
END DEBUG;


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE DEBUG (p_trace_number IN NUMBER)
IS

--
BEGIN
   --
   DEBUG (fnd_number.number_to_canonical (p_trace_number));
--

END DEBUG;

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE DEBUG (p_trace_date IN DATE)
IS

--
BEGIN
   --
   DEBUG (fnd_date.date_to_canonical (p_trace_date));
--

END DEBUG;


-- This procedure is used for debug purposes
-- debug_enter checks the debug flag and sets the trace on/off
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_enter >-------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE debug_enter (p_proc_name IN VARCHAR2, p_trace_on IN VARCHAR2)
IS
BEGIN
   --
   pqp_utilities.debug_enter (
      p_proc_name                   => p_proc_name
     ,p_trace_on                    => p_trace_on
   );
--
END debug_enter;


-- ----------------------------------------------------------------------------
-- |----------------------------< debug_exit >--------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE debug_exit (p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
IS
BEGIN
   --
   pqp_utilities.debug_exit (
      p_proc_name                   => p_proc_name
     ,p_trace_off                   => p_trace_off
   );
--
END debug_exit;


-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_others >--------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE debug_others (p_proc_name IN VARCHAR2, p_proc_step IN NUMBER)
IS
BEGIN
   --
   pqp_utilities.debug_others (
      p_proc_name                   => p_proc_name
     ,p_proc_step                   => p_proc_step
   );
--
END debug_others;

-- Function returns extract result id for a given request id
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_ext_rslt_frm_req >----------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_ext_rslt_frm_req (p_request_id IN NUMBER
                              ,p_ext_dfn_id IN NUMBER
                              )
  RETURN NUMBER IS
--
  CURSOR csr_get_ext_rslt_id
  IS
  SELECT ext_rslt_id
    FROM ben_ext_rslt
   WHERE request_id = p_request_id
     AND ext_dfn_id = p_ext_dfn_id;

  l_ext_rslt_id  NUMBER;
  l_proc_name    VARCHAR2 (80) := g_proc_name
                                 || 'get_ext_rslt_frm_req';
  l_proc_step    NUMBER;

--
BEGIN
  --
  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG (   'Entering: '
            || l_proc_name, l_proc_step);
  END IF;

  OPEN csr_get_ext_rslt_id;
  FETCH csr_get_ext_rslt_id INTO l_ext_rslt_id;

  IF csr_get_ext_rslt_id%NOTFOUND THEN
     fnd_message.set_name ('BEN', 'BEN_91873_EXT_NOT_FOUND');
     fnd_file.put_line(fnd_file.log, 'Error: '
                                    || fnd_message.get);
     fnd_file.put_line(fnd_file.log, ' ');
     CLOSE csr_get_ext_rslt_id;
     fnd_message.raise_error;
  END IF; -- End if of row not found check ...
  CLOSE csr_get_ext_rslt_id;

  IF g_debug
  THEN
     DEBUG (   'Extract Result ID: '
            || TO_CHAR(l_ext_rslt_id));
     l_proc_step                := 20;
     DEBUG (   'Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

  RETURN l_ext_rslt_id;

END get_ext_rslt_frm_req;
--

-- Procedure gets extract result count for a given ext result id
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_ext_rslt_count >------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE get_ext_rslt_count (p_ext_rslt_id  IN            NUMBER
                             ,p_ext_file_id  IN            NUMBER
                             ,p_hdr_count       OUT NOCOPY NUMBER
                             ,p_dtl_count       OUT NOCOPY NUMBER
                             ,p_trl_count       OUT NOCOPY NUMBER
                             ,p_per_count       OUT NOCOPY NUMBER
                             ,p_err_count       OUT NOCOPY NUMBER
                             ,p_tot_count       OUT NOCOPY NUMBER
                             )
  IS
  --
  -- Cursor to get header record count
  --
  CURSOR csr_get_hdr_cnt
  IS
  SELECT COUNT(*)
    FROM ben_ext_rcd_in_file fil
        ,ben_ext_rcd rcd
  WHERE  fil.ext_rcd_id = rcd.ext_rcd_id
    AND  fil.ext_file_id = p_ext_file_id
    AND  rcd.rcd_type_cd = 'H';

  --
  -- Cursor to get trailer record count
  --
  CURSOR csr_get_trl_cnt
  IS
  SELECT COUNT(*)
    FROM   ben_ext_rcd_in_file fil
          ,ben_ext_rcd rcd
   WHERE  fil.ext_rcd_id = rcd.ext_rcd_id
     AND  fil.ext_file_id = p_ext_file_id
     AND  rcd.rcd_type_cd = 'T';
  --
  -- Cursor to get detail record count
  --
  CURSOR csr_get_dtl_cnt
  IS
  SELECT COUNT(*)
    FROM   ben_ext_rslt_dtl xrd
   WHERE  xrd.ext_rslt_id = p_ext_rslt_id;
  --
  -- Cursor to get person record count
  --
  CURSOR csr_get_per_cnt
  IS
  SELECT COUNT(DISTINCT person_id)
    FROM   ben_ext_rslt_dtl xrd
   WHERE  xrd.ext_rslt_id = p_ext_rslt_id
     AND    person_id not in (0, 999999999999);
  --
  -- Cursor to get error record count
  --
  CURSOR csr_get_err_cnt
  IS
  SELECT COUNT(*)
    FROM   ben_ext_rslt_err err
   WHERE  err.ext_rslt_id = p_ext_rslt_id;

  l_hdr_count   NUMBER;
  l_dtl_count   NUMBER;
  l_trl_count   NUMBER;
  l_per_count   NUMBER;
  l_err_count   NUMBER;
  l_tot_count   NUMBER;
  l_proc_name   VARCHAR2 (80) := g_proc_name
                                || 'get_ext_rslt_count';
  l_proc_step   NUMBER;

--
BEGIN

  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG (   'Entering: '
            || l_proc_name, l_proc_step);
  END IF;

  --
  -- Get header count
  --
  OPEN csr_get_hdr_cnt;
  FETCH csr_get_hdr_cnt INTO l_hdr_count;
  CLOSE csr_get_hdr_cnt;

  IF g_debug
  THEN
     l_proc_step                := 20;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  --
  -- Get detail count
  --
  OPEN csr_get_dtl_cnt;
  FETCH csr_get_dtl_cnt INTO l_dtl_count;
  CLOSE csr_get_dtl_cnt;

  IF g_debug
  THEN
     l_proc_step                := 30;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  --
  -- Get trailer count
  --
  OPEN csr_get_trl_cnt;
  FETCH csr_get_trl_cnt INTO l_trl_count;
  CLOSE csr_get_trl_cnt;

  IF g_debug
  THEN
     l_proc_step                := 40;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  --
  -- Get person count
  --
  OPEN csr_get_per_cnt;
  FETCH csr_get_per_cnt INTO l_per_count;
  CLOSE csr_get_per_cnt;

  IF g_debug
  THEN
     l_proc_step                := 50;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  --
  -- Get error count
  --
  OPEN csr_get_err_cnt;
  FETCH csr_get_err_cnt INTO l_err_count;
  CLOSE csr_get_err_cnt;

  l_tot_count := l_hdr_count + l_dtl_count + l_trl_count;

  IF g_debug
  THEN
     DEBUG ('Header Count : '       || TO_CHAR(l_hdr_count));
     DEBUG ('Detail Count : '       || TO_CHAR(l_dtl_count));
     DEBUG ('Trailer Count : '      || TO_CHAR(l_trl_count));
     DEBUG ('Person Count : '       || TO_CHAR(l_per_count));
     DEBUG ('Error Count : '        || TO_CHAR(l_err_count));
     DEBUG ('Total Detail Count : ' || TO_CHAR(l_tot_count));
  END IF;


  IF g_debug
  THEN
     l_proc_step                := 60;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  fnd_file.put_line(fnd_file.log, 'Total Count for extract result ID: '
                                 || TO_CHAR(p_ext_rslt_id));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Header Record Count: '
                                 || TO_CHAR(l_hdr_count));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Detail Record Count: '
                                 || TO_CHAR(l_dtl_count));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Trailer Record Count: '
                                 || TO_CHAR(l_trl_count));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Person Record Count: '
                                 || TO_CHAR(l_per_count));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Error Record Count: '
                                 || TO_CHAR(l_err_count));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Total Detail Record Count: '
                                 || TO_CHAR(l_tot_count));
  fnd_file.new_line(fnd_file.log, 1);


  p_hdr_count := l_hdr_count;
  p_dtl_count := l_dtl_count;
  p_trl_count := l_trl_count;
  p_per_count := l_per_count;
  p_err_count := l_err_count;

  IF g_debug
  THEN
     l_proc_step                := 70;
     DEBUG (   'Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

EXCEPTION
  WHEN others THEN
    p_hdr_count := NULL;
    p_dtl_count := NULL;
    p_trl_count := NULL;
    p_per_count := NULL;
    p_err_count := NULL;
    IF SQLCODE <> hr_utility.hr_error_number
    THEN
         debug_others (l_proc_name, l_proc_step);
         IF g_debug
         THEN
            DEBUG (   'Leaving: '
                   || l_proc_name, -999);
         END IF;
         fnd_message.raise_error;
    ELSE
         RAISE;
    END IF;

END get_ext_rslt_count;
--

-- Procedure creates extract results for a given master ext result id
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_extract_results >--------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_extract_results (p_master_ext_rslt_id           IN NUMBER
                                 ,p_master_request_id            IN NUMBER
                                 ,p_ext_dfn_id                   IN NUMBER
                                 ,p_request_id                   IN NUMBER
                                 ,p_business_group_id            IN NUMBER
                                 ,p_program_application_id       IN NUMBER
                                 ,p_program_id                   IN NUMBER
                                 ,p_effective_date               IN DATE
                                 )
  IS
  --
  --
  -- Cursor to fetch extract result details info
  --
  CURSOR csr_get_ext_rslt_dtl (c_ext_rslt_id NUMBER)
  IS
  SELECT
      prmy_sort_val,
      scnd_sort_val,
      thrd_sort_val,
      trans_seq_num,
      rcrd_seq_num,
      ext_rcd_id,
      person_id,
      val_01,
      val_02,
      val_03,
      val_04,
      val_05,
      val_06,
      val_07,
      val_08,
      val_09,
      val_10,
      val_11,
      val_12,
      val_13,
      val_14,
      val_15,
      val_16,
      val_17,
      val_19,
      val_18,
      val_20,
      val_21,
      val_22,
      val_23,
      val_24,
      val_25,
      val_26,
      val_27,
      val_28,
      val_29,
      val_30,
      val_31,
      val_32,
      val_33,
      val_34,
      val_35,
      val_36,
      val_37,
      val_38,
      val_39,
      val_40,
      val_41,
      val_42,
      val_43,
      val_44,
      val_45,
      val_46,
      val_47,
      val_48,
      val_49,
      val_50,
      val_51,
      val_52,
      val_53,
      val_54,
      val_55,
      val_56,
      val_57,
      val_58,
      val_59,
      val_60,
      val_61,
      val_62,
      val_63,
      val_64,
      val_65,
      val_66,
      val_67,
      val_68,
      val_69,
      val_70,
      val_71,
      val_72,
      val_73,
      val_74,
      val_75,
      business_group_id
    FROM ben_ext_rslt_dtl
   WHERE ext_rslt_id = c_ext_rslt_id;

  l_ext_rslt_dtl_rec  csr_get_ext_rslt_dtl%ROWTYPE;

  --
  -- Cursor to get record type information
  --

  CURSOR csr_get_ext_rcd_ht (c_ext_rcd_id NUMBER)
  IS
  SELECT rcd_type_cd
    FROM ben_ext_rcd
   WHERE ext_rcd_id = c_ext_rcd_id;

  l_ext_rcd_type_cd    ben_ext_rcd.rcd_type_cd%TYPE;

  --
  -- Cursor to get extract result information
  --
  CURSOR csr_get_ext_rslt_err (c_ext_rslt_id NUMBER)
   IS
   SELECT ext_rslt_err_id,
          err_num,
          err_txt,
          typ_cd,
          person_id,
          business_group_id,
          object_version_number,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          ext_rslt_id
     FROM ben_ext_rslt_err
    WHERE ext_rslt_id = c_ext_rslt_id;

  l_ext_rslt_err_rec  csr_get_ext_rslt_err%ROWTYPE;

  l_ext_rslt_dtl_id       NUMBER;
  l_ext_rslt_err_id       NUMBER;
  l_ext_rslt_id           NUMBER;
  l_object_version_number NUMBER;
  l_count_dtl             NUMBER := 0;
  l_count_err             NUMBER := 0;
  l_proc_name             VARCHAR2 (80) := g_proc_name
                                       || 'create_extract_results';
  l_proc_step             NUMBER;
--
BEGIN
  --

  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG (   'Entering: '
            || l_proc_name, l_proc_step);
  END IF;

  fnd_file.put_line(fnd_file.log, 'Processing Request ID: '
                                 || TO_CHAR(p_request_id));
  fnd_file.put_line(fnd_file.log, ' ');

  l_ext_rslt_id := get_ext_rslt_frm_req
                     (p_request_id => p_request_id
                     ,p_ext_dfn_id => p_ext_dfn_id
                     );

  IF l_ext_rslt_id IS NOT NULL THEN

     -- Create copy of extract detail
     -- Get the record type code as we do not want
     -- to create copies of header / trailer unless it is
     -- of master business group

     IF g_debug
     THEN
        l_proc_step                := 20;
        DEBUG (l_proc_name, l_proc_step);
     END IF;

     fnd_file.put_line(fnd_file.log, 'Extract Result ID: '
                                    || TO_CHAR(l_ext_rslt_id));
     fnd_file.put_line(fnd_file.log, ' ');

     OPEN csr_get_ext_rslt_dtl (l_ext_rslt_id);
     LOOP

       FETCH csr_get_ext_rslt_dtl INTO l_ext_rslt_dtl_rec;
       EXIT WHEN csr_get_ext_rslt_dtl%NOTFOUND;

       IF g_debug
       THEN
          l_proc_step                := 30;
          DEBUG (l_proc_name, l_proc_step);
       END IF;

       OPEN csr_get_ext_rcd_ht (l_ext_rslt_dtl_rec.ext_rcd_id);
       FETCH csr_get_ext_rcd_ht INTO l_ext_rcd_type_cd;
       CLOSE csr_get_ext_rcd_ht;

       IF g_debug
       THEN
          DEBUG ('Record Type CD: '
                 || l_ext_rcd_type_cd);
       END IF;

       IF (
           l_ext_rcd_type_cd = 'D'
          )
          OR
          (
           l_ext_rcd_type_cd IN ('H', 'T') AND
           l_ext_rslt_dtl_rec.business_group_id = p_business_group_id
          )
       THEN

          IF g_debug
          THEN
             l_proc_step                := 40;
             DEBUG (l_proc_name, l_proc_step);
          END IF;

          -- Create a copy
          ben_ext_rslt_dtl_api.create_ext_rslt_dtl
                (p_validate                     =>  FALSE
                ,p_ext_rslt_dtl_id              =>  l_ext_rslt_dtl_id
                ,p_prmy_sort_val                =>  l_ext_rslt_dtl_rec.prmy_sort_val
                ,p_scnd_sort_val                =>  l_ext_rslt_dtl_rec.scnd_sort_val
                ,p_thrd_sort_val                =>  l_ext_rslt_dtl_rec.thrd_sort_val
                ,p_trans_seq_num                =>  l_ext_rslt_dtl_rec.trans_seq_num
                ,p_rcrd_seq_num                 =>  l_ext_rslt_dtl_rec.rcrd_seq_num
                ,p_ext_rslt_id                  =>  p_master_ext_rslt_id
                ,p_ext_rcd_id                   =>  l_ext_rslt_dtl_rec.ext_rcd_id
                ,p_person_id                    =>  l_ext_rslt_dtl_rec.person_id
                ,p_business_group_id            =>  p_business_group_id
                ,p_val_01                       =>  l_ext_rslt_dtl_rec.val_01
                ,p_val_02                       =>  l_ext_rslt_dtl_rec.val_02
                ,p_val_03                       =>  l_ext_rslt_dtl_rec.val_03
                ,p_val_04                       =>  l_ext_rslt_dtl_rec.val_04
                ,p_val_05                       =>  l_ext_rslt_dtl_rec.val_05
                ,p_val_06                       =>  l_ext_rslt_dtl_rec.val_06
                ,p_val_07                       =>  l_ext_rslt_dtl_rec.val_07
                ,p_val_08                       =>  l_ext_rslt_dtl_rec.val_08
                ,p_val_09                       =>  l_ext_rslt_dtl_rec.val_09
                ,p_val_10                       =>  l_ext_rslt_dtl_rec.val_10
                ,p_val_11                       =>  l_ext_rslt_dtl_rec.val_11
                ,p_val_12                       =>  l_ext_rslt_dtl_rec.val_12
                ,p_val_13                       =>  l_ext_rslt_dtl_rec.val_13
                ,p_val_14                       =>  l_ext_rslt_dtl_rec.val_14
                ,p_val_15                       =>  l_ext_rslt_dtl_rec.val_15
                ,p_val_16                       =>  l_ext_rslt_dtl_rec.val_16
                ,p_val_17                       =>  l_ext_rslt_dtl_rec.val_17
                ,p_val_19                       =>  l_ext_rslt_dtl_rec.val_19
                ,p_val_18                       =>  l_ext_rslt_dtl_rec.val_18
                ,p_val_20                       =>  l_ext_rslt_dtl_rec.val_20
                ,p_val_21                       =>  l_ext_rslt_dtl_rec.val_21
                ,p_val_22                       =>  l_ext_rslt_dtl_rec.val_22
                ,p_val_23                       =>  l_ext_rslt_dtl_rec.val_23
                ,p_val_24                       =>  l_ext_rslt_dtl_rec.val_24
                ,p_val_25                       =>  l_ext_rslt_dtl_rec.val_25
                ,p_val_26                       =>  l_ext_rslt_dtl_rec.val_26
                ,p_val_27                       =>  l_ext_rslt_dtl_rec.val_27
                ,p_val_28                       =>  l_ext_rslt_dtl_rec.val_28
                ,p_val_29                       =>  l_ext_rslt_dtl_rec.val_29
                ,p_val_30                       =>  l_ext_rslt_dtl_rec.val_30
                ,p_val_31                       =>  l_ext_rslt_dtl_rec.val_31
                ,p_val_32                       =>  l_ext_rslt_dtl_rec.val_32
                ,p_val_33                       =>  l_ext_rslt_dtl_rec.val_33
                ,p_val_34                       =>  l_ext_rslt_dtl_rec.val_34
                ,p_val_35                       =>  l_ext_rslt_dtl_rec.val_35
                ,p_val_36                       =>  l_ext_rslt_dtl_rec.val_36
                ,p_val_37                       =>  l_ext_rslt_dtl_rec.val_37
                ,p_val_38                       =>  l_ext_rslt_dtl_rec.val_38
                ,p_val_39                       =>  l_ext_rslt_dtl_rec.val_39
                ,p_val_40                       =>  l_ext_rslt_dtl_rec.val_40
                ,p_val_41                       =>  l_ext_rslt_dtl_rec.val_41
                ,p_val_42                       =>  l_ext_rslt_dtl_rec.val_42
                ,p_val_43                       =>  l_ext_rslt_dtl_rec.val_43
                ,p_val_44                       =>  l_ext_rslt_dtl_rec.val_44
                ,p_val_45                       =>  l_ext_rslt_dtl_rec.val_45
                ,p_val_46                       =>  l_ext_rslt_dtl_rec.val_46
                ,p_val_47                       =>  l_ext_rslt_dtl_rec.val_47
                ,p_val_48                       =>  l_ext_rslt_dtl_rec.val_48
                ,p_val_49                       =>  l_ext_rslt_dtl_rec.val_49
                ,p_val_50                       =>  l_ext_rslt_dtl_rec.val_50
                ,p_val_51                       =>  l_ext_rslt_dtl_rec.val_51
                ,p_val_52                       =>  l_ext_rslt_dtl_rec.val_52
                ,p_val_53                       =>  l_ext_rslt_dtl_rec.val_53
                ,p_val_54                       =>  l_ext_rslt_dtl_rec.val_54
                ,p_val_55                       =>  l_ext_rslt_dtl_rec.val_55
                ,p_val_56                       =>  l_ext_rslt_dtl_rec.val_56
                ,p_val_57                       =>  l_ext_rslt_dtl_rec.val_57
                ,p_val_58                       =>  l_ext_rslt_dtl_rec.val_58
                ,p_val_59                       =>  l_ext_rslt_dtl_rec.val_59
                ,p_val_60                       =>  l_ext_rslt_dtl_rec.val_60
                ,p_val_61                       =>  l_ext_rslt_dtl_rec.val_61
                ,p_val_62                       =>  l_ext_rslt_dtl_rec.val_62
                ,p_val_63                       =>  l_ext_rslt_dtl_rec.val_63
                ,p_val_64                       =>  l_ext_rslt_dtl_rec.val_64
                ,p_val_65                       =>  l_ext_rslt_dtl_rec.val_65
                ,p_val_66                       =>  l_ext_rslt_dtl_rec.val_66
                ,p_val_67                       =>  l_ext_rslt_dtl_rec.val_67
                ,p_val_68                       =>  l_ext_rslt_dtl_rec.val_68
                ,p_val_69                       =>  l_ext_rslt_dtl_rec.val_69
                ,p_val_70                       =>  l_ext_rslt_dtl_rec.val_70
                ,p_val_71                       =>  l_ext_rslt_dtl_rec.val_71
                ,p_val_72                       =>  l_ext_rslt_dtl_rec.val_72
                ,p_val_73                       =>  l_ext_rslt_dtl_rec.val_73
                ,p_val_74                       =>  l_ext_rslt_dtl_rec.val_74
                ,p_val_75                       =>  l_ext_rslt_dtl_rec.val_75
                ,p_program_application_id       =>  p_program_application_id
                ,p_program_id                   =>  p_program_id
                ,p_program_update_date          =>  SYSDATE
                ,p_request_id                   =>  p_master_request_id
                ,p_object_version_number        =>  l_object_version_number
                );
           l_count_dtl := l_count_dtl + 1;


         END IF; -- End if of record type check ...

        END LOOP;
        CLOSE csr_get_ext_rslt_dtl;

        --
        -- Create copy of extract error records if one exist
        --

        IF g_debug
        THEN
           l_proc_step                := 50;
           DEBUG (l_proc_name, l_proc_step);
        END IF;

        OPEN csr_get_ext_rslt_err (l_ext_rslt_id);
        LOOP

          FETCH csr_get_ext_rslt_err INTO l_ext_rslt_err_rec;
          EXIT WHEN csr_get_ext_rslt_err%NOTFOUND;

          -- create a copy of extract result error

          IF g_debug
          THEN
             l_proc_step                := 60;
             DEBUG (l_proc_name, l_proc_step);
          END IF;

          ben_ext_rslt_err_api.create_ext_rslt_err
                (p_validate                     =>  FALSE
                ,p_ext_rslt_err_id              =>  l_ext_rslt_err_id
                ,p_err_num                      =>  l_ext_rslt_err_rec.err_num
                ,p_err_txt                      =>  l_ext_rslt_err_rec.err_txt
                ,p_typ_cd                       =>  l_ext_rslt_err_rec.typ_cd
                ,p_person_id                    =>  l_ext_rslt_err_rec.person_id
                ,p_business_group_id            =>  p_business_group_id
                ,p_object_version_number        =>  l_object_version_number
                ,p_request_id                   =>  p_master_request_id
                ,p_program_application_id       =>  p_program_application_id
                ,p_program_id                   =>  p_program_id
                ,p_program_update_date          =>  SYSDATE
                ,p_ext_rslt_id                  =>  p_master_ext_rslt_id
                ,p_effective_date               =>  p_effective_date
                );

           l_count_err := l_count_err + 1;

        END LOOP;
        CLOSE csr_get_ext_rslt_err;
    END IF; -- End if of ext result id is not null check ...

  IF g_debug
  THEN
     DEBUG ('Total Detail Records Created: '
            || TO_CHAR(l_count_dtl));
     DEBUG ('Total Error Records Created: '
            || TO_CHAR(l_count_err));
  END IF;

  fnd_file.put_line(fnd_file.log, 'Total Detail Records Created: '
                                 || TO_CHAR(l_count_dtl));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Total Error Records Created: '
                                 || TO_CHAR(l_count_err));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Finished Processing Request ID: '
                                 || TO_CHAR(p_request_id));
  fnd_file.new_line(fnd_file.log, 1);

  IF g_debug
  THEN
     l_proc_step                := 70;
     DEBUG (   'Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

END create_extract_results;
--
-- Procedure copy_extract_results for a given set of request ids
--
-- ----------------------------------------------------------------------------
-- |----------------------------< copy_extract_results >----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE copy_extract_results
           (p_tab_request_ids       IN pqp_gb_tp_ext_process.t_request_ids_type
           ,p_ext_dfn_id            IN NUMBER
           ,p_master_business_group IN NUMBER
           )
IS

  CURSOR csr_get_ext_rslt_info (c_request_id NUMBER)
  IS
  SELECT ext_rslt_id
        ,eff_dt
        ,ext_strt_dt
        ,ext_end_dt
        ,drctry_name
        ,output_name
    FROM ben_ext_rslt
   WHERE request_id        = c_request_id
     AND ext_dfn_id        = p_ext_dfn_id
     AND business_group_id = p_master_business_group;

  --
  -- Cursor to get file id
  --
  CURSOR csr_get_ext_param
  IS
  SELECT ext_file_id
        ,output_name
        ,apnd_rqst_id_flag
        ,kickoff_wrt_prc_flag
    FROM ben_ext_dfn
   WHERE ext_dfn_id = p_ext_dfn_id;

  l_ext_param_rec         csr_get_ext_param%ROWTYPE;
  l_ext_rslt_info_rec     csr_get_ext_rslt_info%ROWTYPE;
  l_master_ext_rslt_id    NUMBER;
  l_ext_rslt_id           NUMBER;
  l_master_request_id     NUMBER := fnd_global.conc_request_id;
  l_master_prog_appl_id   NUMBER := fnd_global.prog_appl_id;
  l_master_program_id     NUMBER := fnd_global.conc_program_id;
  l_tab_request_ids       pqp_gb_tp_ext_process.t_request_ids_type
                                 := p_tab_request_ids;
  i                       NUMBER;
  l_effective_date        DATE;
  l_object_version_number NUMBER;
  l_hdr_count             NUMBER := 0;
  l_dtl_count             NUMBER := 0;
  l_trl_count             NUMBER := 0;
  l_per_count             NUMBER := 0;
  l_err_count             NUMBER := 0;
  l_tot_count             NUMBER := 0;
  l_output_name           VARCHAR2(200); -- Do not use type
  l_request_id            NUMBER;
  l_val_02                ben_ext_rslt_dtl.val_02%TYPE;
  l_val_03                ben_ext_rslt_dtl.val_03%TYPE;
  l_proc_name             VARCHAR2 (80) := g_proc_name
                                       || 'copy_extract_results';
  l_proc_step             NUMBER;

BEGIN

  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG (   'Entering: '
            || l_proc_name, l_proc_step);
  END IF;
  --
  -- Create an extract result first for this request id
  --
  i := l_tab_request_ids.FIRST;

  WHILE i IS NOT NULL
  LOOP

    IF g_debug
    THEN
       l_proc_step                := 20;
       DEBUG (l_proc_name, l_proc_step);
    END IF;

    OPEN csr_get_ext_rslt_info (l_tab_request_ids(i));
    FETCH csr_get_ext_rslt_info INTO l_ext_rslt_info_rec;
    IF csr_get_ext_rslt_info%FOUND THEN

       IF g_debug
       THEN
          DEBUG ('Master Business Group Request ID: '
                 || TO_CHAR(l_tab_request_ids(i)));
       END IF;

       fnd_file.put_line(fnd_file.log, 'Master Business Group Request ID: '
                                      || TO_CHAR(l_tab_request_ids(i)));
       fnd_file.put_line(fnd_file.log, ' ');
       CLOSE csr_get_ext_rslt_info;
       EXIT;
    END IF; -- End if of ext result found check ...
    CLOSE csr_get_ext_rslt_info;

    i := l_tab_request_ids.NEXT(i);
  END LOOP;

  IF l_ext_rslt_info_rec.ext_rslt_id IS NULL THEN
     -- Error
     -- There is no result for master business group
     fnd_message.set_name ('BEN', 'BEN_91873_EXT_NOT_FOUND');
     fnd_file.put_line(fnd_file.log, 'Error: '
                                    || fnd_message.get);
     fnd_file.put_line(fnd_file.log, ' ');
     fnd_message.raise_error;
  END IF; -- End if of ext rslt id null check ...

  --
  -- Fetch the file id for the extract
  --
  IF g_debug
  THEN
     l_proc_step                := 30;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  OPEN csr_get_ext_param;
  FETCH csr_get_ext_param INTO l_ext_param_rec;

  IF csr_get_ext_param%NOTFOUND THEN
     fnd_message.set_name ('BEN', 'BEN_91873_EXT_NOT_FOUND');
     fnd_file.put_line(fnd_file.log, 'Error: '
                                    || fnd_message.get);
     fnd_file.put_line(fnd_file.log, ' ');
     CLOSE csr_get_ext_param;
     fnd_message.raise_error;
  END IF; -- End if of row not found check ...
  CLOSE csr_get_ext_param;

  IF g_debug
  THEN
     l_proc_step                := 40;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  IF l_ext_param_rec.output_name IS NOT NULL AND
     l_ext_param_rec.apnd_rqst_id_flag = 'Y'
  THEN
      --
      l_output_name := l_ext_param_rec.output_name || '.' ||
                       TO_CHAR(l_master_request_id);
      --
  ELSE
      l_output_name := 'outfile';
  END IF; -- End if of output name not null check ...

  IF g_debug
  THEN
     DEBUG ('Master Request ID: '
            || TO_CHAR(l_master_request_id));
     DEBUG ('Output File Name: '
            || l_output_name);
     l_proc_step                := 40;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  fnd_file.put_line(fnd_file.log, 'Master Request ID: '
                                 || TO_CHAR(l_master_request_id));
  fnd_file.put_line(fnd_file.log, ' ');

  ben_ext_rslt_api.create_ext_rslt
         (p_validate                => FALSE
         ,p_ext_rslt_id             => l_master_ext_rslt_id
         ,p_run_strt_dt             => SYSDATE
         ,p_run_end_dt              => NULL
         ,p_ext_stat_cd             => 'X'
         ,p_eff_dt                  => l_ext_rslt_info_rec.eff_dt
         ,p_ext_strt_dt             => l_ext_rslt_info_rec.ext_strt_dt
         ,p_ext_end_dt              => l_ext_rslt_info_rec.ext_end_dt
         ,p_output_name             => l_output_name
         ,p_drctry_name             => l_ext_rslt_info_rec.drctry_name
         ,p_ext_dfn_id              => p_ext_dfn_id
         ,p_business_group_id       => p_master_business_group
         ,p_program_application_id  => l_master_prog_appl_id
         ,p_program_id              => l_master_program_id
         ,p_program_update_date     => SYSDATE
         ,p_request_id              => l_master_request_id
         ,p_object_version_number   => l_object_version_number
         ,p_effective_date          => l_ext_rslt_info_rec.eff_dt);

  IF g_debug
  THEN
     DEBUG ('Master Result ID: '
            || TO_CHAR(l_master_ext_rslt_id));
     l_proc_step                := 50;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  fnd_file.put_line(fnd_file.log, 'Master Result ID: '
                                 || TO_CHAR(l_master_ext_rslt_id));
  fnd_file.put_line(fnd_file.log, ' ');

  i := l_tab_request_ids.FIRST;

  WHILE i IS NOT NULL
  LOOP

      IF g_debug
      THEN
         DEBUG ('Request ID: '
               || TO_CHAR(l_tab_request_ids(i)));
         l_proc_step                := 60;
         DEBUG (l_proc_name, l_proc_step);
      END IF;

      create_extract_results
        (p_master_ext_rslt_id      => l_master_ext_rslt_id
        ,p_master_request_id       => l_master_request_id
        ,p_ext_dfn_id              => p_ext_dfn_id
        ,p_request_id              => l_tab_request_ids(i)
        ,p_business_group_id       => p_master_business_group
        ,p_program_application_id  => l_master_prog_appl_id
        ,p_program_id              => l_master_program_id
        ,p_effective_date          => l_ext_rslt_info_rec.eff_dt
        );

        i := l_tab_request_ids.NEXT(i);
  END LOOP;

  --
  -- Get extract result count
  --

  IF g_debug
  THEN
     l_proc_step                := 70;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  get_ext_rslt_count
    (p_ext_rslt_id => l_master_ext_rslt_id
    ,p_ext_file_id => l_ext_param_rec.ext_file_id
    ,p_hdr_count   => l_hdr_count
    ,p_dtl_count   => l_dtl_count
    ,p_trl_count   => l_trl_count
    ,p_per_count   => l_per_count
    ,p_err_count   => l_err_count
    ,p_tot_count   => l_tot_count
    );

  IF g_debug
  THEN
     l_proc_step                := 80;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  --
  -- Update trailer data element with the correct value
  --
  ben_ext_thread.g_ext_rslt_id := l_master_ext_rslt_id;
  l_val_02 := pqp_gb_tp_pension_extracts.get_total_number_data_records(' ');
  l_val_03 := pqp_gb_tp_pension_extracts.get_total_number_data_records('1');

  IF g_debug
  THEN
     DEBUG ('Total Number of Data Records: '
            || l_val_02);
     DEBUG ('Total Number of Type 1 Data Records: '
            || l_val_03);
     l_proc_step                := 90;
     DEBUG (l_proc_name, l_proc_step);
  END IF;

  UPDATE ben_ext_rslt_dtl rslt
     SET val_02 = l_val_02
        ,val_03 = l_val_03
   WHERE ext_rslt_id = l_master_ext_rslt_id
     AND EXISTS ( SELECT 1 FROM ben_ext_rcd rcd
                   WHERE rcd.ext_rcd_id = rslt.ext_rcd_id
                     AND rcd.rcd_type_cd = 'T'
                );
  --
  -- update master ext rslt with the count details
  --
  IF l_err_count > 0 THEN
  --
  -- Call update API to update Extract Run Rslts row here
  -- Extract status - Completed with Errors
  --

    IF g_debug
    THEN
       l_proc_step                := 100;
       DEBUG (l_proc_name, l_proc_step);
    END IF;

    ben_ext_rslt_api.update_ext_rslt
      (p_validate                       => FALSE
      ,p_ext_rslt_id                    => l_master_ext_rslt_id
      ,p_run_end_dt                     => SYSDATE
      ,p_ext_stat_cd                    => 'E'
      ,p_tot_rec_num                    => l_tot_count
      ,p_tot_per_num                    => l_per_count
      ,p_tot_err_num                    => l_err_count
      ,p_program_application_id         => l_master_prog_appl_id
      ,p_program_id                     => l_master_program_id
      ,p_program_update_date            => SYSDATE
      ,p_request_id                     => l_master_request_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => l_ext_rslt_info_rec.eff_dt);
  --

  ELSE
    --
    IF g_debug
    THEN
       l_proc_step                := 110;
       DEBUG (l_proc_name, l_proc_step);
    END IF;

    ben_ext_rslt_api.update_ext_rslt
      (p_validate                       => FALSE
      ,p_ext_rslt_id                    => l_master_ext_rslt_id
      ,p_run_end_dt                     => SYSDATE
      ,p_ext_stat_cd                    => 'S'
      ,p_tot_rec_num                    => l_tot_count
      ,p_tot_per_num                    => l_per_count
      ,p_tot_err_num                    => l_err_count
      ,p_program_application_id         => l_master_prog_appl_id
      ,p_program_id                     => l_master_program_id
      ,p_program_update_date            => SYSDATE
      ,p_request_id                     => l_master_request_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => l_ext_rslt_info_rec.eff_dt);

  END IF; -- End if of err count > 0 check ...

  IF l_master_request_id IS NOT NULL THEN


    IF l_ext_param_rec.kickoff_wrt_prc_flag = 'Y' THEN
    --
       IF g_debug
       THEN
          l_proc_step                := 120;
          DEBUG (l_proc_name, l_proc_step);
       END IF;

        l_request_id := fnd_request.submit_request
                  (application => 'BEN',
                   program     => 'BENXWRIT',
                   description => NULL,
                   sub_request => FALSE,
                   argument1   => l_master_ext_rslt_id);
    --
    END IF; -- End if of kick off write process flag check ...
  END IF; -- End if of master request id not null check ...

  IF g_debug
  THEN
     l_proc_step                := 130;
     DEBUG ('Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

END copy_extract_results;
--
-- Procedure copy_extract_process is a wrapper for copy_extract_results
-- so that it can be used as a concurrent program
--
-- ----------------------------------------------------------------------------
-- |----------------------------< copy_extract_process >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE copy_extract_process (errbuf              OUT NOCOPY VARCHAR2
                               ,retcode             OUT NOCOPY NUMBER
                               ,p_ext_dfn_id        IN NUMBER
                               ,p_business_group_id IN NUMBER
                               ,p_request_id_1      IN NUMBER
                               ,p_request_id_2      IN NUMBER
                               ,p_request_id_3      IN NUMBER
                               ,p_request_id_4      IN NUMBER
                               ,p_request_id_5      IN NUMBER
                               )
IS
  --
  l_tab_request_ids pqp_gb_tp_ext_process.t_request_ids_type;
  i                 NUMBER;
  j                 NUMBER;
  l_request_id      NUMBER;
  l_proc_name             VARCHAR2 (80) := g_proc_name
                                       || 'copy_extract_results';
  l_proc_step             NUMBER;

  --
BEGIN
  --
  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG ('Entering: '
            || l_proc_name, l_proc_step);
  END IF;

  i := 0;
  j := 0;

  LOOP
    i := i + 1;
    SELECT DECODE
            (i
            ,1, p_request_id_1
            ,2, p_request_id_2
            ,3, p_request_id_3
            ,4, p_request_id_4
            ,5, p_request_id_5
            ,NULL
            )
      INTO l_request_id
      FROM dual;

    IF l_request_id IS NOT NULL THEN

       IF g_debug
       THEN
          DEBUG ('Include Request ID: '
                 || TO_CHAR(l_request_id));
       END IF;

       j := j + 1;
       l_tab_request_ids(j) := l_request_id;
    END IF;  -- End if of request id not null check ...

    EXIT WHEN i >= 5;
  END LOOP;

  IF l_tab_request_ids.COUNT > 1 THEN

    IF g_debug
    THEN
       l_proc_step                := 20;
       DEBUG (l_proc_name, l_proc_step);
    END IF;

    copy_extract_results (p_tab_request_ids       => l_tab_request_ids
                         ,p_ext_dfn_id            => p_ext_dfn_id
                         ,p_master_business_group => p_business_group_id
                         );
  END IF;
  IF g_debug
  THEN
     l_proc_step                := 30;
     DEBUG ('Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

END copy_extract_process;

--
-- set_location_code
--
PROCEDURE set_location_code
             (p_udt_id                  IN NUMBER
             ,p_value                   IN VARCHAR2
             ,p_business_group_id       IN NUMBER
             ) IS

  c_effective_date       CONSTANT DATE := to_date('01/01/1951','dd/mm/yyyy');

  CURSOR csr_user_col IS
  SELECT user_column_id
  FROM pay_user_columns
  WHERE user_table_id = p_udt_id
    AND user_column_name = 'Location Code'
    AND legislation_code = 'GB'
    AND business_group_id IS NULL;

  CURSOR csr_user_row IS
  SELECT user_row_id
  FROM pay_user_rows_f
  WHERE user_table_id = p_udt_id
    AND row_low_range_or_name = 'Criteria'
    AND c_effective_date BETWEEN effective_start_date
                             AND effective_end_date
    AND legislation_code = 'GB'
    AND business_group_id IS NULL;


  CURSOR csr_udt_location_code IS
  SELECT uci.rowid, uci.*
  FROM pay_user_columns puc
      ,pay_user_rows_f pur
      ,pay_user_column_instances_f uci
  WHERE -- User Column
        puc.user_table_id = p_udt_id
    AND puc.user_column_name = 'Location Code'
    AND puc.legislation_code = 'GB'
    AND puc.business_group_id IS NULL
    -- User Row
    AND pur.row_low_range_or_name = 'Criteria'
    AND c_effective_date BETWEEN pur.effective_start_date
                             AND pur.effective_end_date
    AND pur.legislation_code = 'GB'
    AND pur.business_group_id IS NULL
    -- Join column and Col Instance
    AND uci.user_column_id = puc.user_column_id
    -- join row and Col Instance
    AND uci.user_row_id = pur.user_row_id
    -- Filter instance on date and BG
    AND uci.business_group_id = p_business_group_id
    AND ((c_effective_date BETWEEN uci.effective_start_date
                              AND uci.effective_end_date
         )
         OR
         (uci.effective_start_date > c_effective_date
         )
        )
  ORDER BY uci.effective_start_date ASC;

  l_udt_row     csr_udt_location_code%ROWTYPE;

  l_proc_name           VARCHAR2 (80) := g_proc_name
                                          || 'set_location_code';


BEGIN

  --hr_utility.trace_on(NULL, 'REQID');
  --g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug('Entering :'||l_proc_name, 10);
    debug('p_udt_id :'||to_char(p_udt_id), 20);
    debug('p_business_group_id :'||to_char(p_business_group_id), 30);
    debug('p_value :'||p_value, 40);
  END IF;

  FOR l_udt_row IN csr_udt_location_code
  LOOP

    PAY_USER_COLUMN_INSTANCES_PKG.delete_row(l_udt_row.rowid);

    IF g_debug THEN
      debug('Deleted row in loop', 50);
    END IF;
    /* Use the new API when made available, currently only in NOV03 FP
    pay_user_column_instance_api.delete_user_column_instance
      (p_validate                      => FALSE
      ,p_effective_date                => l_udt_row.effective_start_date
      ,p_user_column_instance_id       => l_udt_row.user_column_instance_id
      ,p_datetrack_update_mode         => hr_api.g_zap
      ,p_object_version_number         => l_udt_row.object_version_number
      ,p_effective_start_date          => l_udt_row.effective_start_date
      ,p_effective_end_date            => l_udt_row.effective_start_date
      );
   */

  END LOOP;

  l_udt_row := NULL;

  OPEN csr_user_col;
  FETCH csr_user_col INTO l_udt_row.user_column_id;
  CLOSE csr_user_col;

  OPEN csr_user_row;
  FETCH csr_user_row INTO l_udt_row.user_row_id;
  CLOSE csr_user_row;

  IF g_debug THEN
    debug('User Row Id :'||to_char(l_udt_row.user_row_id), 60);
    debug('User Col  Id :'||to_char(l_udt_row.user_column_id), 70);
  END IF;

  -- Now insert a new row with the correct location code
  PAY_USER_COLUMN_INSTANCES_PKG.insert_row
      (p_rowid                   => l_udt_row.rowid
      ,p_user_column_instance_id => l_udt_row.user_column_instance_id
      ,p_effective_start_date    => c_effective_date
      ,p_effective_end_date      => hr_api.g_eot
      ,p_user_row_id             => l_udt_row.user_row_id
      ,p_user_column_id          => l_udt_row.user_column_id
      ,p_business_group_id       => p_business_group_id
      ,p_legislation_code        => NULL
      ,p_legislation_subgroup    => NULL
      ,p_value                   => p_value
      );

  /* Use the new API when made available, currently only in NOV03 FP
  pay_user_column_instance_api.create_user_column_instance
    (p_validate                      => FALSE
    ,p_effective_date                => c_effective_date
    ,p_user_row_id                   => l_udt_row.user_row_id
    ,p_user_column_id                => l_udt_row.user_column_id
    ,p_value                         => p_value
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => NULL
    ,p_user_column_instance_id       => l_udt_row.user_column_instance_id
    ,p_object_version_number         => l_udt_row.object_version_number
    ,p_effective_start_date          => l_udt_row.effective_start_date
    ,p_effective_end_date            => l_udt_row.effective_end_date
    );
   */

  IF g_debug THEN
    debug('Leaving :'||l_proc_name, 90);
  END IF;
   --hr_utility.trace_off;

EXCEPTION
 WHEN OTHERS THEN
   --hr_utility.trace_off;
   RAISE;
END set_location_code;

--
-- set_cross_person_records
--
PROCEDURE set_cross_person_records
  (p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE
  ,p_master_request_id  IN NUMBER
  -- Bugfix 3671727:ENH2 :Added new param
  ,p_ext_dfn_id         IN VARCHAR2
  ) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_wait_success        BOOLEAN := FALSE;

  l_phase        VARCHAR2(80);
  l_status       VARCHAR2(80);
  l_dev_phase    VARCHAR2(80);
  l_dev_status   VARCHAR2(80);
  l_message      VARCHAR2(80);

  l_multiproc_data      pqp_gb_t1_pension_extracts.csr_multiproc_data%ROWTYPE;

  l_proc_name           VARCHAR2 (80) := g_proc_name
                                          || 'set_cross_person_records';


BEGIN -- set_cross_person_records

  IF g_debug THEN
    debug('Entering :'||l_proc_name, 10);
  END IF;

  -- Get the master row data
  OPEN pqp_gb_t1_pension_extracts.csr_multiproc_data
                        (p_record_type => 'M'
                        ,p_national_identifier => NULL
                        -- Bugfix 3671727:ENH1: Now passing lea number
                        ,p_lea_number  => g_lea_number
                        ,p_ext_dfn_id  => p_ext_dfn_id
                        );
  FETCH pqp_gb_t1_pension_extracts.csr_multiproc_data INTO l_multiproc_data;

  IF pqp_gb_t1_pension_extracts.csr_multiproc_data%FOUND THEN

    IF g_debug THEN
      debug('Found row in csr_multiproc_data', 20);
    END IF;

    -- Found, now chk for status
    IF NVL(l_multiproc_data.processing_status, 'U') <> 'P' THEN

      l_wait_success := TRUE;

    ELSE -- Another request might be running currently

      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;

      -- Verify by chking the status of the request id
      -- stored in the master bg row
      l_wait_success := fnd_concurrent.get_request_status
                          (request_id  => l_multiproc_data.request_id
                          ,phase      => l_phase          -- OUT
                          ,status     => l_status         -- OUT
                          ,dev_phase  => l_dev_phase      -- OUT
                          ,dev_status => l_dev_status     -- OUT
                          ,message    => l_message        -- OUT
                          );

      IF l_wait_success
         AND
         l_dev_phase = 'COMPLETE' THEN

        l_wait_success := TRUE;
      ELSE
        l_wait_success := FALSE;
      END IF;

    END IF; -- NVL(l_multiproc_data.processing_status, 'U') <> 'P' THEN

    IF l_wait_success THEN
      UPDATE pqp_ext_cross_person_records
         SET business_group_id     = p_business_group_id
            ,effective_start_date  = p_effective_date
            ,request_id            = nvl(p_master_request_id, g_master_request_id)
            ,processing_status     = 'P' -- Processing
            ,last_updated_by       = fnd_global.user_id
            ,last_update_date      = SYSDATE
            ,last_update_login     = fnd_global.login_id
            ,object_version_number = (object_version_number + 1)
       WHERE record_type = 'M'
         -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
         AND ext_dfn_id = p_ext_dfn_id
         AND lea_number = g_lea_number;

      IF g_debug THEN
        debug('No of rows updated :'||to_char(SQL%ROWCOUNT), 40);
        debug('Updated master BG row with :'||to_char(p_business_group_id), 50);
      END IF;

    ELSE
      -- Raise error with message that there is already
      -- another TPA Master Extract Process running,
      -- can not submit a second one
      CLOSE pqp_gb_t1_pension_extracts.csr_multiproc_data;

      -- Exiting because another process is running and you can not submit twice
      fnd_message.set_name('PQP', 'PQP_230036_MULTIPLE_TP_EXT_ERR');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      fnd_message.raise_error;
      RETURN;

    END IF;

    l_wait_success := NULL;

  ELSE -- NOTFOUND

    -- Not found, insert a new master bg row
    -- Bugfix 3671727:ENH1:ENH2 : Added ext_dfn_id and lea_number
    INSERT INTO pqp_ext_cross_person_records
    (record_type
    ,ext_dfn_id
    ,lea_number
    ,business_group_id
    ,effective_start_date
    ,request_id
    ,processing_status
    ,created_by
    ,creation_date
    ,object_version_number
    )
    VALUES
    ('M' -- Master BG row
    ,p_ext_dfn_id
    ,g_lea_number
    ,p_business_group_id
    ,p_effective_date
    ,nvl(p_master_request_id, g_master_request_id)
    ,'P' -- Processing
    ,fnd_global.user_id
    ,SYSDATE
    ,1
    );

    IF g_debug THEN
      debug('Inserted master BG row with :'||to_char(p_business_group_id), 60);
    END IF;

  END IF; -- pqp_gb_t1_pension_extracts.csr_multiproc_data%FOUND THEN

  -- Close the cursor if its still open
  IF pqp_gb_t1_pension_extracts.csr_multiproc_data%ISOPEN THEN
    CLOSE pqp_gb_t1_pension_extracts.csr_multiproc_data;
  END IF;

  -- Step 3.2) Updating multiproc data
  UPDATE pqp_ext_cross_person_records
     SET processing_status = 'U'
        ,last_updated_by       = fnd_global.user_id
        ,last_update_date      = SYSDATE
        ,last_update_login     = fnd_global.login_id
        ,object_version_number = (object_version_number + 1)
   WHERE record_type = 'X'
     -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
     AND ext_dfn_id = p_ext_dfn_id
     AND lea_number = g_lea_number;

  -- Commiting here before any further processing
  -- coz we have updated data in the multiproc table
  -- and this will be used by all the child processes
  COMMIT;

  IF g_debug THEN
    debug('Leaving :'||l_proc_name, 90);
  END IF;
  RETURN;

END set_cross_person_records;

--
-- fail_current_extract_run
--
PROCEDURE fail_current_extract_run
  (p_ext_dfn_id IN NUMBER
  ) IS

  l_proc_name           VARCHAR2 (80) := g_proc_name
                                          || 'fail_current_extract_run';

BEGIN

  IF g_debug THEN
    debug('Entering :'||l_proc_name, 10);
  END IF;

  -- Error out as the current BG is not an LEA
  -- Also, we need to reset the master BG row in multiproc data
  -- table to 'E'
  UPDATE pqp_ext_cross_person_records
     SET processing_status       = 'E' -- Error
        ,last_updated_by       = fnd_global.user_id
        ,last_update_date      = SYSDATE
        ,last_update_login     = fnd_global.login_id
        ,object_version_number = (object_version_number + 1)
   WHERE record_type = 'M'
     -- Bugfix 3671727:ENH1 : Added these AND clauses
     AND ext_dfn_id = p_ext_dfn_id
     AND lea_number = g_lea_number;

  COMMIT;

  IF g_debug THEN
    debug('Leaving :'||l_proc_name, 90);
  END IF;

  RETURN;

END fail_current_extract_run;
--
-- tpa_extract_process
--
PROCEDURE tpa_extract_process
  (errbuf               OUT NOCOPY      VARCHAR2
  ,retcode              OUT NOCOPY      NUMBER
  ,p_ext_dfn_id         IN              NUMBER
  ,p_effective_date     IN              VARCHAR2
  ,p_business_group_id  IN              NUMBER
  ,p_lea_yn             IN              VARCHAR2
  ,p_argument1          IN              VARCHAR2
  ,p_organization_id    IN              NUMBER
  -- Bugfix 3671727:ENH1 : Added new param
  ,p_argument2          IN              VARCHAR2
  ,p_lea_number         IN              VARCHAR2
  ) IS

  CURSOR csr_location_code IS
  SELECT loc.location_code
        ,loc.location_id
        ,lei.lei_information6 lea_number
    FROM hr_organization_units_v org
        ,hr_locations_all loc
        ,hr_location_extra_info lei
  WHERE org.organization_id = p_organization_id
    AND loc.location_id = org.location_id
    AND lei.location_id(+) = loc.location_id
    AND nvl(lei.information_type,'PQP_GB_EDU_ESTB_INFO') = 'PQP_GB_EDU_ESTB_INFO';

  CURSOR csr_bg_name(p_business_group_id IN NUMBER) IS
  SELECT name
  FROM per_business_groups_perf
  WHERE business_group_id = p_business_group_id;

  PROGRAM_FAILURE   CONSTANT NUMBER := 2 ;
  PROGRAM_SUCCESS   CONSTANT NUMBER := 0 ;

  l_location_code       hr_locations_all.location_code%TYPE := NULL;
  l_location_id         hr_locations_all.location_id%TYPE := NULL;
  l_curr_bg_id          per_all_people_f.business_group_id%TYPE;
  l_request_id          fnd_concurrent_requests.request_id%TYPE;
  l_retcode             NUMBER := PROGRAM_SUCCESS;
  l_wait_success        BOOLEAN := FALSE;
  l_effective_date      DATE;

  l_phase        VARCHAR2(80);
  l_status       VARCHAR2(80);
  l_dev_phase    VARCHAR2(80);
  l_dev_status   VARCHAR2(80);
  l_message      VARCHAR2(80);
  l_err_msg      fnd_new_messages.message_text%TYPE;

  l_lea_details         pqp_gb_tp_pension_extracts.csr_lea_details%ROWTYPE;
  l_lea_dets_frm_bg     pqp_gb_tp_pension_extracts.csr_lea_details%ROWTYPE;
  l_multiproc_data      pqp_gb_t1_pension_extracts.csr_multiproc_data%ROWTYPE;
  l_lea_dets_by_loc     pqp_gb_tp_pension_extracts.csr_lea_details_by_loc%ROWTYPE;

  l_ext_udt_id          pay_user_tables.user_table_id%TYPE;
  l_bg_name             per_business_groups_perf.name%TYPE := NULL;

  l_proc_name           VARCHAR2 (80) := g_proc_name
                                          || 'tpa_extract_process';

BEGIN -- tpa_extract_process

  --hr_utility.trace_on(NULL, 'REQID');
  --g_debug := hr_utility.debug_enabled;

  l_effective_date := fnd_date.canonical_to_date(p_effective_date);

  -- Step 1) Get the master request id
  g_master_request_id := fnd_global.conc_request_id;

  IF g_debug THEN
    debug('Entering :'||l_proc_name, 10);
    debug('g_master_request_id :'||to_char(g_master_request_id), 20);
  END IF;

  -- Step 2) Set report type, LEA or Non-LEA
  --         If its the LEA report then we set the location
  --         code as NULL in UDT, otherwise, we find the
  --         location code, find the UDT name and set the
  --         location code in the UDT for the Non-LEA report.

  -- Step 2.1) Check report type

  -- Bugifix in 115.5
  -- Checking if its an LEA report using the p_lea_yn flag instead of
  --  comparing the org id and bg id coz for non lea report
  --  we might have a situation where the location has been
  --  linked to the BG org for using with non lea report
  IF p_lea_yn = 'Y' THEN

    g_report_type := 'LEA';

    -- Clear the location code from the UDT as we're
    -- running the LEA report
    l_location_code := NULL;
    l_location_id   := NULL;

    -- Bugfix 3671727:ENH1 :Setting the LEA number
    g_lea_number := p_lea_number;

  ELSE -- Check report type

    IF g_debug THEN
      debug(l_proc_name, 30);
    END IF;

    g_report_type := 'NONLEA';

    -- Step 2.2) Get the location id for this organization
    --           and set the location code in the UDT
    --           so the non-Lea report gets executed
    -- Bugfix 3671727:ENH1 : Now getting the location id and LEA number
    OPEN csr_location_code;
    FETCH csr_location_code INTO l_location_code, l_location_id, g_lea_number;
    CLOSE csr_location_code;

    -- Bugfix 3671727:ENH1 : If the LEA number was NULL on location EIT then
    --  get it from the following in that order
    --    1) Org linked to that location
    --    2) The BG
    IF g_lea_number IS NULL THEN

      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;

      -- Step 1) Getting LEA Number from Org linked to the location
      OPEN pqp_gb_tp_pension_extracts.csr_lea_details_by_loc(l_location_id);
      FETCH pqp_gb_tp_pension_extracts.csr_lea_details_by_loc INTO l_lea_dets_by_loc;

      IF (pqp_gb_tp_pension_extracts.csr_lea_details_by_loc%FOUND
          AND
          l_lea_dets_by_loc.lea_number IS NOT NULL
        ) THEN

        g_lea_number := l_lea_dets_by_loc.lea_number;

      ELSE
        -- LEA Number is not present on org linked to location
        IF g_debug THEN
          debug(l_proc_name, 45);
        END IF;

        -- Step 2) Look for LEA Number at BG level
        OPEN pqp_gb_tp_pension_extracts.csr_lea_details
                  (p_organization_id => p_business_group_id
                  ,p_lea_number      => NULL
                  );
        FETCH pqp_gb_tp_pension_extracts.csr_lea_details INTO l_lea_dets_frm_bg;

        IF (pqp_gb_tp_pension_extracts.csr_lea_details%FOUND
            AND
            l_lea_dets_frm_bg.lea_number IS NOT NULL
           ) THEN

          g_lea_number := l_lea_dets_frm_bg.lea_number;

        ELSE -- NOT FOUND or LEA Number is NULL

          -- Close both cursors
          CLOSE pqp_gb_tp_pension_extracts.csr_lea_details_by_loc;
          CLOSE pqp_gb_tp_pension_extracts.csr_lea_details;

          -- Error out as the current BG is not set up as an LEA
          fail_current_extract_run(p_ext_dfn_id => p_ext_dfn_id);

          fnd_message.set_name('PQP', 'PQP_230037_CURR_BG_NOT_LEA_ERR');
          l_err_msg := fnd_message.get;
          errbuf  := l_err_msg;
          retcode := PROGRAM_FAILURE;
          fnd_file.put_line(fnd_file.log, l_err_msg);

          fnd_message.raise_error;

          RETURN;

        END IF; -- Chk Lea number from BG Level

        CLOSE pqp_gb_tp_pension_extracts.csr_lea_details;

      END IF; -- Step 1) Getting LEA Number from Org linked to the location

      CLOSE pqp_gb_tp_pension_extracts.csr_lea_details_by_loc;

    END IF; -- g_lea_number IS NULL
    --
  END IF; -- Check report type

  IF g_debug THEN
    debug('g_report_type :'||g_report_type, 50);
    debug('g_lea_number  :'||g_lea_number, 60);
    debug('l_location_code :'||nvl(l_location_code,'NULL'), 70);
  END IF;

  -- Step 2.3) Get the UDT name using p_ext_dfn_id
  OPEN pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes(p_ext_dfn_id);
  FETCH pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes
        INTO g_extract_type, g_extract_udt_name, l_ext_udt_id;
  CLOSE pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes;

  -- Step 2.4) Update the UDT in the current Master BG
  set_location_code
    (p_udt_id                  => l_ext_udt_id
    ,p_value                   => l_location_code
    ,p_business_group_id       => p_business_group_id
    );

  -- Step 3) Set the master Bg in the multiproc data table
  --         and also update multiproc data with status of
  --         U for unprocessed
  -- This step has now been moved into the procedure set_cross_person_records
  -- Bugfix 3671727:ENH2 :Passing new param p_ext_dfn_id
  set_cross_person_records
    (p_business_group_id  => p_business_group_id
    ,p_effective_date     => l_effective_date
    ,p_ext_dfn_id         => p_ext_dfn_id
    );

  -- Step 4) Find the details of this BG / organization
  --         Also find any other LEA BGs enabled for cross BG
  --         reporting and store them all for processing

  -- Step 4.1) Get the LEA details of the chosen LEA in the current BG
  g_lea_business_groups.DELETE;

  OPEN pqp_gb_tp_pension_extracts.csr_lea_details
                (p_organization_id => p_business_group_id
                -- Bugfix 3671727:ENH1 Now fetching for chosen LEA
                ,p_lea_number      => g_lea_number
                );
  FETCH pqp_gb_tp_pension_extracts.csr_lea_details INTO l_lea_details;

  IF pqp_gb_tp_pension_extracts.csr_lea_details%NOTFOUND THEN

    CLOSE pqp_gb_tp_pension_extracts.csr_lea_details;

    -- Error out as the current BG does not hv this LEA
    -- Bugfix 3671727:ENH1:ENH2 :Moved code from here into new proc
    --          as we need to call it from more than one places
    fail_current_extract_run(p_ext_dfn_id => p_ext_dfn_id);

    fnd_message.set_name('PQP', 'PQP_230037_CURR_BG_NOT_LEA_ERR');
    l_err_msg := fnd_message.get;
    errbuf  := l_err_msg;
    retcode := PROGRAM_FAILURE;
    fnd_file.put_line(fnd_file.log, l_err_msg);

    fnd_message.raise_error;

    RETURN;

  END IF;

  CLOSE pqp_gb_tp_pension_extracts.csr_lea_details;

  -- Step 4.2) Store the current master BG in the list of BGs to process
  g_lea_business_groups(p_business_group_id).business_group_id := p_business_group_id;
  -- Bugfix 3671727:ENH1 Commented out as these cols are not available in the collection
  -- g_lea_business_groups(p_business_group_id).lea_number := l_lea_details.lea_number;
  -- g_lea_business_groups(p_business_group_id).lea_name := l_lea_details.lea_name;
  g_lea_business_groups(p_business_group_id).CrossBG_Enabled := l_lea_details.crossbg_enabled;

  IF g_debug THEN
    debug('Count in BGs collection :'||to_char(g_lea_business_groups.COUNT), 80);
    debug('LEA Number :'||l_lea_details.lea_number, 90);
  END IF;

  -- Step 4.3) If its the LEA report, then we need to find,
  -- store and process other LEA BGs enabled for Cross BG reporting.
  -- For Non-LEA report, we just run for current BG and location code
  IF g_report_type = 'LEA'
     AND
     l_lea_details.crossbg_enabled = 'Y' THEN

    -- Loop thru all the LEA BGs enabled for Cross BG reporting
    FOR l_BG_dets IN pqp_gb_t1_pension_extracts.csr_all_business_groups
                             (l_lea_details.lea_number
                             ,p_business_group_id
                             )
    LOOP

      -- Update the location code in the UDT for this BG
      set_location_code
        (p_udt_id                  => l_ext_udt_id
        ,p_value                   => l_location_code
        ,p_business_group_id       => l_BG_dets.business_group_id
        );

      -- Store all LEA BGs enabled for bross BG reporting
      g_lea_business_groups(l_BG_dets.business_group_id) := l_BG_dets;

      IF g_debug THEN
        debug('Added to collection BGId :'||to_char(l_BG_dets.business_group_id), 100);
      END IF;

    END LOOP;

    IF g_debug THEN
      debug('Count in BGs collection :'||to_char(g_lea_business_groups.COUNT), 110);
    END IF;

  END IF;

  -- Commit here as we hv set location code in one or more UDTs
  COMMIT;

  -- Step 5) For each stored LEA Bg, submit an extract process
  l_curr_bg_id := g_lea_business_groups.FIRST;

  WHILE l_curr_bg_id IS NOT NULL
  LOOP

    IF g_debug THEN
      debug('Submitting Request', 120);
    END IF;

    -- Submit the extract process request
    l_request_id := fnd_request.submit_request
                        (application => 'BEN'
                        ,program     => 'BENXTRCT'
                        ,description => to_char(l_curr_bg_id)
                        ,sub_request => FALSE -- TRUE, still not decide on this one
                        ,argument1   => NULL -- benefit_action_id
                        ,argument2   => fnd_number.number_to_canonical(p_ext_dfn_id)
                        ,argument3   => p_effective_date -- is already canonical
                        ,argument4   => fnd_number.number_to_canonical(l_curr_bg_id)
                        );

    IF l_request_id = 0 THEN

      OPEN csr_bg_name(l_curr_bg_id);
      FETCH csr_bg_name INTO l_bg_name;
      CLOSE csr_bg_name;

      fnd_message.set_name('PQP', 'PQP_230038_EXT_PROC_SUBMIT_ERR');
      fnd_message.set_token('BGNAME', l_bg_name);
      l_err_msg := fnd_message.get;
      errbuf := l_err_msg;
      fnd_file.put_line(fnd_file.log, l_err_msg);
      l_retcode := PROGRAM_FAILURE ;
      l_err_msg := NULL;
      EXIT;
    END IF;

    COMMIT;

    IF g_debug THEN
      debug('BGId :'||to_char(l_curr_bg_id)||' Request ID :'||to_char(l_request_id), 130);
    END IF;

    -- If the execution mode is serial then
    -- we must wait for this request to complete
    -- before submitting the next one.
    IF g_execution_mode = 'SERIAL' THEN

      l_wait_success := fnd_concurrent.wait_for_request
                          (request_id => l_request_id
                          ,interval   => g_wait_interval
                          ,max_wait   => g_max_wait
                          ,phase      => l_phase          -- OUT
                          ,status     => l_status         -- OUT
                          ,dev_phase  => l_dev_phase      -- OUT
                          ,dev_status => l_dev_status     -- OUT
                          ,message    => l_message        -- OUT
                          );

      -- Do some error checking here
      IF (NOT l_wait_success
         )
         OR
         (l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
         ) THEN

        fnd_file.put_line(fnd_file.log, l_message);

        l_bg_name := NULL;
        OPEN csr_bg_name(l_curr_bg_id);
        FETCH csr_bg_name INTO l_bg_name;
        CLOSE csr_bg_name;

        fnd_message.set_name('PQP', 'PQP_230039_EXT_PROC_EXEC_ERR');
        fnd_message.set_token('BGNAME', l_bg_name);
        l_err_msg := fnd_message.get;
        errbuf := l_err_msg;
        fnd_file.put_line(fnd_file.log, l_err_msg);
        l_retcode := PROGRAM_FAILURE ;
        l_err_msg := NULL;
        EXIT;

      ELSE -- Completed successfully

        IF g_debug THEN
          debug('SERIAL: Completed Successfully Request ID :'||to_char(l_request_id), 140);
        END IF;

        -- Store the request id in BG collection
        g_lea_business_groups(l_curr_bg_id).request_id := l_request_id;
        g_request_ids(l_curr_bg_id) := l_request_id;

      END IF;

    ELSE -- PARALLEL, store request id for chking later
      g_lea_business_groups(l_curr_bg_id).request_id := l_request_id;
      g_request_ids(l_curr_bg_id) := l_request_id;
    END IF; -- g_execution_mode = 'SERIAL' THEN

    -- Get the next BG
    l_curr_bg_id := g_lea_business_groups.NEXT(l_curr_bg_id);

  END LOOP; -- l_curr_bg_id IS NOT NULL

  -- Step 5.2) Check the return code for any failure
  IF l_retcode = PROGRAM_FAILURE THEN

    IF g_debug THEN
      debug('SERIAL:Program Failure, erroring.', 150);
    END IF;

    -- First reset the status on multiproc data for master bg row
    UPDATE pqp_ext_cross_person_records
       SET processing_status = 'E' -- Error
          ,last_updated_by       = fnd_global.user_id
          ,last_update_date      = SYSDATE
          ,last_update_login     = fnd_global.login_id
          ,object_version_number = (object_version_number + 1)
     WHERE record_type = 'M'
       -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
       AND ext_dfn_id = p_ext_dfn_id
       AND lea_number = g_lea_number;

    COMMIT;

    retcode := l_retcode;
    fnd_message.raise_error;
    RETURN;

  END IF;

  -- Step 6) Wait till all extract processes finish
  -- If the execution mode is parallel then we
  -- must wait for all the requests to complete
  -- before proceeding.
  IF g_execution_mode = 'PARALLEL' THEN

    l_curr_bg_id := g_lea_business_groups.FIRST;

    WHILE l_curr_bg_id IS NOT NULL
    LOOP

      l_wait_success := fnd_concurrent.wait_for_request
                          (request_id => g_lea_business_groups(l_curr_bg_id).request_id
                          ,interval   => g_wait_interval
                          ,max_wait   => g_max_wait
                          ,phase      => l_phase          -- OUT
                          ,status     => l_status         -- OUT
                          ,dev_phase  => l_dev_phase      -- OUT
                          ,dev_status => l_dev_status     -- OUT
                          ,message    => l_message        -- OUT
                          );

      -- Do some error checking here
      IF (NOT l_wait_success
         )
         OR
         (l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
         ) THEN

        fnd_file.put_line(fnd_file.log, l_message);

        l_bg_name := NULL;
        OPEN csr_bg_name(l_curr_bg_id);
        FETCH csr_bg_name INTO l_bg_name;
        CLOSE csr_bg_name;

        fnd_message.set_name('PQP', 'PQP_230039_EXT_PROC_EXEC_ERR');
        fnd_message.set_token('BGNAME', l_bg_name);
        l_err_msg := fnd_message.get;
        errbuf := l_err_msg;
        fnd_file.put_line(fnd_file.log, l_err_msg);
        l_retcode := PROGRAM_FAILURE ;
        l_err_msg:= NULL;
        EXIT;

      END IF; -- (l_dev_phase = 'COMPLETE'

      IF g_debug THEN
        debug('PARALLEL:Completed Request ID :'||
                        to_char(g_lea_business_groups(l_curr_bg_id).request_id), 160);
      END IF;

      l_curr_bg_id := g_lea_business_groups.NEXT(l_curr_bg_id);

    END LOOP; -- l_curr_bg_id IS NOT NULL

    -- Step 6.2) Check the return code for any failure
    IF l_retcode = PROGRAM_FAILURE THEN

      IF g_debug THEN
        debug('PARALLEL:Program Failure, erroring.', 170);
      END IF;

      -- First reset the status on multiproc data for master bg row
      UPDATE pqp_ext_cross_person_records
         SET processing_status = 'E' -- Error
            ,last_updated_by       = fnd_global.user_id
            ,last_update_date      = SYSDATE
            ,last_update_login     = fnd_global.login_id
            ,object_version_number = (object_version_number + 1)
       WHERE record_type = 'M'
         -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
         AND ext_dfn_id = p_ext_dfn_id
         AND lea_number = g_lea_number;

      COMMIT;

      retcode := l_retcode;
      fnd_message.raise_error;
      RETURN;
    END IF;

  END IF; -- g_execution_mode = 'PARALLEL' THEN

  -- Step 7) Call the extract results merge/copy process
  --         only if there are more than one request ids
  --         in the collection

  IF g_request_ids.COUNT > 1 THEN

    copy_extract_results
          (p_tab_request_ids              => g_request_ids
          ,p_ext_dfn_id                   => p_ext_dfn_id
          ,p_master_business_group        => p_business_group_id
          );

  END IF; -- End if of collection count > 1 check ...

  -- Step 8) Reset the processing status in master Bg
  --         and multiproc rows
  UPDATE pqp_ext_cross_person_records
     SET processing_status = 'C' -- Completed
        ,last_updated_by       = fnd_global.user_id
        ,last_update_date      = SYSDATE
        ,last_update_login     = fnd_global.login_id
        ,object_version_number = (object_version_number + 1)
   WHERE record_type = 'M'
     -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
     AND ext_dfn_id = p_ext_dfn_id
     AND lea_number = g_lea_number;

  UPDATE pqp_ext_cross_person_records
     SET processing_status = 'U' -- Back to Unprocessed
        ,last_updated_by       = fnd_global.user_id
        ,last_update_date      = SYSDATE
        ,last_update_login     = fnd_global.login_id
        ,object_version_number = (object_version_number + 1)
   WHERE record_type = 'X'
     -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
     AND ext_dfn_id = p_ext_dfn_id
     AND lea_number = g_lea_number;

  COMMIT;

  -- Write a summary in the log file
  fnd_file.put_line(fnd_file.log, 'Teachers Pension Extract Process completed successfully.');
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Total business groups processed :'
                        ||to_char(g_lea_business_groups.COUNT));
  fnd_file.put_line(fnd_file.log, ' ');
  fnd_file.put_line(fnd_file.log, 'Business Group Id   Request Id     ');
  fnd_file.put_line(fnd_file.log, '-----------------   ---------------');

  l_curr_bg_id := g_lea_business_groups.FIRST;

  WHILE l_curr_bg_id IS NOT NULL
  LOOP

    fnd_file.put(fnd_file.log, rpad(to_char(l_curr_bg_id), 20));
    fnd_file.put_line
      (fnd_file.log
      ,rpad(to_char(g_lea_business_groups(l_curr_bg_id).request_id), 15)
      );

    l_curr_bg_id := g_lea_business_groups.NEXT(l_curr_bg_id);

  END LOOP;

  IF g_debug THEN
    debug('Completed master process.', 180);
    debug('Leaving :'||l_proc_name, 190);
  END IF;

  --hr_utility.trace_off;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
      debug('Other in :'||l_proc_name, 200);
    END IF;
    -- First reset the status on multiproc data for master bg row
    UPDATE pqp_ext_cross_person_records
       SET processing_status = 'E' -- Error
          ,last_updated_by       = fnd_global.user_id
          ,last_update_date      = SYSDATE
          ,last_update_login     = fnd_global.login_id
          ,object_version_number = (object_version_number + 1)
     WHERE record_type = 'M'
       -- Bugfix 3671727:ENH1:ENH2 : Added these AND clauses
       AND ext_dfn_id = p_ext_dfn_id
       AND lea_number = g_lea_number;


    COMMIT;
    RAISE;
END tpa_extract_process;

--
--
--

END pqp_gb_tp_ext_process;

/
