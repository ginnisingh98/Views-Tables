--------------------------------------------------------
--  DDL for Package Body OKC_QP_UPGRADE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QP_UPGRADE_PUB" AS
/* $Header: OKCPQPUB.pls 120.0 2005/05/25 22:36:14 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  OKC_QP_UPGRADE_PUB.';  -- Global package name
--
g_error_exception          exception;
g_category_code            okc_subclasses_b.code%TYPE;
g_dflt_price_list_id       number;
g_k_price_list_id          number;

FUNCTION get_seq_id RETURN NUMBER;

FUNCTION get_item_to_price_flag (p_lse_id IN NUMBER ) RETURN VARCHAR2;

/*----------------------------------------------------------------------------
        PROCEDURE upgrade_contracts
----------------------------------------------------------------------------*/
PROCEDURE upgrade_contracts
(
 errbuf                   OUT NOCOPY  VARCHAR2,
 retcode                  OUT NOCOPY  VARCHAR2,
 p_dflt_price_list_id     IN   NUMBER,
 p_category_code          IN   okc_subclasses_b.code%TYPE ,
 p_enable_qp_profile      IN   VARCHAR2  ,
 p_rpt_upgrade_status     IN   VARCHAR2
)
IS
/*
  This is the concurrent program called with the following parameters :

1. p_dflt_price_list_id : This is a Required Parameter. If the priced lines don't have any pricing
   rules attached to them or any level above them and if there is no pricing rule attached at the
   contract header , price_list_id for the priced lines will be defaulted to the user entered
   parameter p_dflt_price_list_id

   Validation :
   This parameter is required.

2. p_category_code : The user can specify the category of the contracts which he wants to upgrade.
   If he user does not specify the category, the concurrent program will fetch
   ALL categories for core contracts of classes belonging to OKC or OKO and run the upgrade.

   Validation:
   At any given point of time, only one concurrent program can be in progress for a category.
   If the user specifies a category whose upgrade is in Progress i.e completion_flag = P
   we will skip that category

3. p_enable_qp_profile : After all the contracts have been upgraded and the user has run
   the exceptions scripts and verified the report, the user can use this option to enable
   the OKC Advanced Pricing Profile option.

   Validation:
   This option can only be used only after all the contracts have been successfully upgraded.

4. p_rpt_upgrade_status : This will Report all the categories that have been upgraded and
   list any categories that are not yet upgraded.

   Validation:
   None

*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'upgrade_contracts';

-- sessionid for log
CURSOR csr_sessionid IS
SELECT USERENV('sessionid')
FROM dual;

l_sessionid                  number;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
    okc_util.init_trace;
    fnd_file.put_line(FND_FILE.LOG,'Trace Mode is Enabled');
  END IF;

  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'        Starting Concurrent Program ... ');
  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_dflt_price_list_id   :      '||p_dflt_price_list_id,2);
     okc_debug.Log('20: p_category_code        :      '||p_category_code,2);
     okc_debug.Log('20: p_enable_qp_profile    :      '||p_enable_qp_profile,2);
     okc_debug.Log('20: p_rpt_upgrade_status   :      '||p_rpt_upgrade_status,2);
  END IF;


  -- get the sessionid
  OPEN csr_sessionid;
    FETCH csr_sessionid INTO l_sessionid;
  CLOSE csr_sessionid;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('25: Session ID :  '||l_sessionid,2);
     okc_debug.Log('25: User ID :     '||fnd_global.user_id,2);
     okc_debug.Log('25: Conc Req ID : '||fnd_global.conc_request_id,2);
  END IF;

  -- log session details
  fnd_file.put_line(FND_FILE.LOG,' ********** DATABASE TRACE INFORMATION*************** ');
  fnd_file.put_line(FND_FILE.LOG,'Session id :  '||l_sessionid);
  fnd_file.put_line(FND_FILE.LOG,'User id :     '||fnd_global.user_id);
  fnd_file.put_line(FND_FILE.LOG,'Conc Req id : '||fnd_global.conc_request_id);
  fnd_file.put_line(FND_FILE.LOG,' **************************************************** ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');

  -- log messages with parameters
  fnd_file.put_line(FND_FILE.LOG,' *********   Program Parameters **************** ');
  fnd_file.put_line(FND_FILE.LOG,'Default Price List : '||p_dflt_price_list_id);
  fnd_file.put_line(FND_FILE.LOG,'Category Code :      '||p_category_code);
  fnd_file.put_line(FND_FILE.LOG,'Enable QP Profile :  '||p_enable_qp_profile);
  fnd_file.put_line(FND_FILE.LOG,'Upgrade Status Rpt : '||p_rpt_upgrade_status);
  fnd_file.put_line(FND_FILE.LOG,' **************************************************** ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');

  -- assign the global variable value for default price list
    g_dflt_price_list_id  := p_dflt_price_list_id;

  -- check if profile value and abort if Y
  IF NVL(check_qp_profile,'N') = 'N' THEN

  -- check if OKC_QP_UPGRADE modifier is defined
     IF NVL(check_modifier,'N') = 'Y' THEN

  -- process params
/*
    Parameters are processed in the following order :
    1. Category
    2. Enable Profile
    3. Run Report
*/

     -- Parameter 1 : Category

     -- Run Upgrade for category

        IF (l_debug = 'Y') THEN
           okc_debug.Log('500: Calling call_qp_upgrade ',2);
        END IF;

           call_qp_upgrade
           (
            p_category_code       =>  p_category_code
           );

      -- Parameter 2 : Enable Profile
     IF NVL(p_enable_qp_profile,'N') = 'Y' THEN
           -- update the summary to complete and enable the profile
           upd_summary_rec;
     END IF;


   END IF; -- modifier is defined

 END IF; -- profile value is N

  -- Upgrade Report Can always be run even if the Profile is already set to Y

      -- Parameter 3 : Upgrade Report
      IF NVL(p_rpt_upgrade_status,'N') = 'Y' THEN
        -- process report
        process_report;
      END IF;



  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');
  fnd_file.put_line(FND_FILE.LOG,'Completed Concurrent Program. ');
  fnd_file.put_line(FND_FILE.LOG,' ---------------------------------------------------------- ');

  IF (l_debug = 'Y') THEN
     okc_debug.Log('500: Calling Stop Trace and Leaving ',2);
     okc_debug.Log('1000: Leaving ',2);
  END IF;

  IF NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
    -- print debug information
    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,' ********** Debug Messages ********************* ');
    fnd_file.put_line(FND_FILE.LOG,'For Debug Messages run the following SQL : ');
    fnd_file.put_line(FND_FILE.LOG,'SELECT * FROM fnd_log_messages WHERE user_id = '||fnd_global.user_id||
                      ' AND session_id = '||l_sessionid||' ORDER BY log_sequence; ');
    fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
    fnd_file.put_line(FND_FILE.LOG,'  ');
    fnd_file.put_line(FND_FILE.LOG,'  ');
    -- stop trace mode
    okc_util.stop_trace;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Reset_Indentation;
  END IF;


EXCEPTION
  WHEN g_error_exception THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('2000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    -- update the Category record as done with error
       upd_category_rec
       (
        p_category_code    =>   g_category_code,
        p_status           =>   'N'
       );
     raise;
  WHEN others THEN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('3000: Leaving ',2);
       okc_debug.Reset_Indentation;
    END IF;
    raise;
END upgrade_contracts;



/*----------------------------------------------------------------------------
        PROCEDURE ins_summary_rec
----------------------------------------------------------------------------*/
PROCEDURE ins_summary_rec
IS
/*
  This procedure will insert record in okc_qp_upgrade process with line_type
  as SUMMARY.
  There can be only one record in okc_qp_upgrade with line_type=SUMMARY.
  If the record already exists then this procedure will not do any thing.
*/
-- local variables and cursors

l_proc                       varchar2(72) := g_package||'ins_summary_rec';
l_qp_upgrade_rec             okc_qp_upgrade%ROWTYPE;

CURSOR csr_summary_rec IS
SELECT *
FROM okc_qp_upgrade
WHERE line_type='SUMMARY';

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'     ins_summary_rec                              ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

  OPEN csr_summary_rec;
    FETCH csr_summary_rec INTO l_qp_upgrade_rec;
      IF csr_summary_rec%NOTFOUND THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('20: Summary Record Not Found, Inserting ... ',2);
        END IF;
       -- record does not exist, so insert
       INSERT INTO okc_qp_upgrade
       (
         LINE_TYPE,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         COMPLETION_FLAG,
         SCS_CODE,
         CHR_ID,
         REQUEST_ID,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN
       )
       VALUES
       (
         'SUMMARY',
         sysdate,
         sysdate,
         'N',
         NULL,
         NULL,
         fnd_global.conc_request_id,
         fnd_global.user_id,
         fnd_global.user_id,
         fnd_global.conc_login_id
       );

       -- commit the record
        commit;

        IF (l_debug = 'Y') THEN
           okc_debug.Log('30: Inserted Summary Record ',2);
        END IF;
        -- fnd_file.put_line(FND_FILE.LOG,'Inserted Summary Record');

      ELSE
        -- Summary Record found, don't insert
        IF (l_debug = 'Y') THEN
           okc_debug.Log('40: Summary Record FOUND, skipping insert ',2);
        END IF;
        -- fnd_file.put_line(FND_FILE.LOG,'Summary Record Already Exits');
      END IF; -- record does not exist
  CLOSE csr_summary_rec;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END ins_summary_rec;


/*----------------------------------------------------------------------------
        PROCEDURE ins_category_rec
----------------------------------------------------------------------------*/
PROCEDURE ins_category_rec
(
 p_category_code  IN   okc_subclasses_b.code%TYPE
)
IS
/*
 This procedure will insert record into okc_qp_upgrade with line_type=CATEGORY
 There will be only ONE ROW in okc_qp_upgrade for each category.
 This proc will check if the if record for the category exists
 ----------------
 Record Not Found:
 ----------------
  1. Insert record for the category
  2. Commit record
  3. Call the upgrade of K for this category.

 ----------------
 Record Found:
 ----------------
   Case 1 :  completion_flag = 'Y'
     In this case this category was already upgraded
        skip this category
   Case 2 :  completion_flag = 'N'
     In this case there was an error when the conc. pgm was run for the category
      1. update completion_flag = 'P' -- In Progress
      2. Commit record
      3. Call the upgrade of K for this category.
   Case 3 : completion_flag = 'P'
      In this case there is another concurrent pgm being run for this category.
      So we skip this category as only ONE conc. pgm can run at any point of time for a
      given category

*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'ins_category_rec';
l_qp_upgrade_rec             okc_qp_upgrade%ROWTYPE;

CURSOR csr_category_rec IS
SELECT *
FROM okc_qp_upgrade
WHERE line_type = 'CATEGORY'
  AND scs_code = p_category_code
FOR UPDATE OF completion_flag;

l_status        varchar2(10);

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('15: Category Code : '||p_category_code ,2);
  END IF;
/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'       ins_category_rec                           ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

  OPEN csr_category_rec;
    FETCH csr_category_rec INTO l_qp_upgrade_rec;
  IF (l_debug = 'Y') THEN
     okc_debug.set_trace_off;
  END IF;
    IF csr_category_rec%NOTFOUND THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('20: Category Record Not Found, Inserting ... ',2);
        END IF;
       -- record does not exist, so insert
       INSERT INTO okc_qp_upgrade
       (
         LINE_TYPE,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         COMPLETION_FLAG,
         SCS_CODE,
         CHR_ID,
         REQUEST_ID,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN
       )
       VALUES
       (
         'CATEGORY',
         sysdate,
         sysdate,
         'P',
         p_category_code,
         NULL,
         fnd_global.conc_request_id,
         fnd_global.user_id,
         fnd_global.user_id,
         fnd_global.conc_login_id
       );

       -- commit the record
        commit;

        IF (l_debug = 'Y') THEN
           okc_debug.Log('30: Inserted Category Record for : '||p_category_code,2);
           okc_debug.Log('35: Calling Upgrade for category : '||p_category_code,2);
        END IF;

      -- populate the global variable with this cat_code it is processing
         g_category_code  := p_category_code ;

       --  fnd_file.put_line(FND_FILE.LOG,'Starting Upgrade For Category : '||p_category_code);

       -- call upgrade for this category
          start_category_upgrade
          (
           p_category_code     =>  p_category_code
          );
        IF (l_debug = 'Y') THEN
           okc_debug.set_trace_off;
        END IF;

           l_status := 'Y';

        -- update the Category record as done
             upd_category_rec
             (
              p_category_code    =>   p_category_code,
              p_status           =>   l_status
             );
           IF (l_debug = 'Y') THEN
              okc_debug.set_trace_off;
           END IF;
       fnd_file.put_line(FND_FILE.LOG,'Completed Upgrade For Category : '||p_category_code);

      ELSE
        -- Category Record found, don't insert

        IF (l_debug = 'Y') THEN
           okc_debug.Log('40: Category Record FOUND ',2);
           okc_debug.Log('40: completion_flag : '||l_qp_upgrade_rec.completion_flag,2);
        END IF;

         IF l_qp_upgrade_rec.completion_flag = 'Y' THEN
          /*
           Case 1 :  completion_flag = 'Y'
           In this case this category was already upgraded, so skip
          */
              IF (l_debug = 'Y') THEN
                 okc_debug.Log('50: Skipping as category is already Upgraded : '||p_category_code,2);
              END IF;
              fnd_message.set_name('OKC','OKC_CATEGORY_UPGRADED');
              fnd_message.set_token('CATEGORY',p_category_code);
              fnd_file.put_line(FND_FILE.LOG,fnd_message.get);

         ELSIF l_qp_upgrade_rec.completion_flag = 'N' THEN
              /*
                Case 2 :  completion_flag = 'N'
                In this case there was an error when the conc. pgm was run for the category
              */
               --  1. update completion_flag = P ,
                UPDATE okc_qp_upgrade
                   SET completion_flag = 'P'
                WHERE CURRENT OF csr_category_rec;


                -- 2. Commit record
                commit;

                IF (l_debug = 'Y') THEN
                   okc_debug.Log('60: Updated completion_flag to P for : '||p_category_code,2);
                   okc_debug.Log('70: Calling Upgrade for category : '||p_category_code,2);
                END IF;

              -- populate the global variable with this cat_code it is processing
                 g_category_code  := p_category_code ;


               -- fnd_file.put_line(FND_FILE.LOG,'3: Starting Upgrade For Category : '||p_category_code);

                -- 3. Call the upgrade of K for this category.
                     start_category_upgrade
                     (
                      p_category_code     =>  p_category_code
                     );

                   IF (l_debug = 'Y') THEN
                      okc_debug.set_trace_off;
                   END IF;
                    -- we ran for all contracts
                       l_status := 'Y';

                    -- update the Category record as done
                         upd_category_rec
                         (
                          p_category_code    =>   p_category_code,
                          p_status           =>   l_status
                         );
                  IF (l_debug = 'Y') THEN
                     okc_debug.set_trace_off;
                  END IF;
                    fnd_file.put_line(FND_FILE.LOG,':Completed Upgrade For Category : '||p_category_code);

         ELSE
              /*
               Case 3 : completion_flag = 'P'
               In this case there is another concurrent pgm being run for this category.
               So we skip this category as only ONE conc. pgm can run at any point of time for a
               given category
               */
               IF (l_debug = 'Y') THEN
                  okc_debug.Log('80: Another conc pgm IN PROGRESS for : '||p_category_code,2);
                  okc_debug.Log('100: Skipping Category : '||p_category_code,2);
               END IF;
               fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
               fnd_message.set_name('OKC','OKC_CATEGORY_UPG_PROGESS');
               fnd_message.set_token('CATEGORY',p_category_code);
               fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
               fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');

         END IF; -- completion_flag

      END IF; -- record does not exist
  CLOSE csr_category_rec;
 IF (l_debug = 'Y') THEN
    okc_debug.set_trace_on;
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
 END IF;

EXCEPTION
  WHEN others THEN
       IF (l_debug = 'Y') THEN
          okc_debug.set_trace_on;
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
       END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END ins_category_rec;


/*----------------------------------------------------------------------------
        PROCEDURE start_category_upgrade
----------------------------------------------------------------------------*/
PROCEDURE start_category_upgrade
(
 p_category_code          IN   okc_subclasses_b.code%TYPE
)
IS
/*
 This procedure will call the upgrade script .
 we will run upgrade for ALL contracts in p_category_code
 which have NOT BEEN UPGRADED i.e no entry in okc_qp_upgrade table.

*/
-- local variables and cursors

l_proc                       varchar2(72) := g_package||'start_category_upgrade';

--select all the contracts of application OKC and OKO which are of SELL Intent
 CURSOR chr_cursor IS
  SELECT chr1.rowid,
         chr1.id id,
         chr1.contract_number,
         chr1.contract_number_modifier,
         chr1.estimated_amount ,
         chr1.object_version_number obj
  FROM okc_k_headers_b chr1
  WHERE chr1.application_id IN (510,871)
    AND NVL(chr1.buy_or_sell,'X') = 'S'
    AND chr1.scs_code = p_category_code
    AND chr1.id NOT IN
                 (
                  SELECT NVL(chr_id,0)
                    FROM okc_qp_upgrade
                  WHERE line_type = 'CONTRACT'
                    AND scs_code  = p_category_code
                 )
    ;


 TYPE num_tbl_type is table of number index by binary_integer;
 TYPE varchar_tbl_type is table of varchar2(30) index by binary_integer;
 TYPE RowIDTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

 l_batch_size number:= 100;
 l_counter    number:= 0;
--
 l_hdr_list_price number;              -- holds total list price for the header
 l_line_list_price number :=0;         -- holds list price for the current priced line
 l_cle_id number;                      -- holds next line id to be traversed
 l_qty number :=0;
 i pls_integer;                        --used as index for the main loop
 j pls_integer;                        --used as index for the inner loop
 k pls_integer;                        -- used to hold the index for the priced line
 l pls_integer;                        -- generic index, used in searching for the rule on a line
 l_price_list_id number;
 l_obj_code varchar2(30);
 l_hdr_price_list number;              -- holds pricelist id for the header, if any

 l_line_rowid_tbl  RowIDTab;
 l_line_id_tbl num_tbl_type;          -- holds line ids for a contract header
 l_level_tbl num_tbl_type;            -- holds row level for lines
 l_cle_id_tbl num_tbl_type;           -- holds parent id of the lines
 l_line_list_price_tbl num_tbl_type;  -- holds list price of the line
 l_price_unit_tbl num_tbl_type;       -- holds unit price for the priced line
 l_priced_flag_tbl  varchar_tbl_type; -- holds priced flag value for lines
 l_price_list_tbl num_tbl_type;       -- holds pricelist for the line
 l_obj_code_tbl varchar_tbl_type;     -- holds object version number for the line. needed in update
 l_rul_line_id_tbl       num_tbl_type;
 l_rul_header_id_tbl     num_tbl_type;

 l_rul_pricelist_tbl num_tbl_type;
 l_rul_object_code_tbl varchar_tbl_type;

-- skekkar
 l_itm_to_price_tbl         varchar_tbl_type;      -- holds item_to_price_yn for lse_id for lines in okc_k_lines_b
 l_lse_id_tbl               num_tbl_type;         -- holds lse_id for lines in okc_k_lines_b
 l_user_estimated_amount    number := 0;
 l_estimated_amount         number := 0;
-- skekkar

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'     start_category_upgrade                       ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

--for all the contracts selected, rollup list prices and get pricelists for lines
FOR chr_rec IN chr_cursor LOOP   --#1
--
 l_hdr_price_list := null;
 l_hdr_list_price:=0;
 l_level_tbl.delete;
 l_line_id_tbl.delete;
 l_cle_id_tbl.delete;
 l_line_list_price_tbl.delete;
 l_price_unit_tbl.delete;
 l_priced_flag_tbl.delete;
 l_price_list_tbl.delete;
 l_rul_line_id_tbl .delete;
 l_rul_pricelist_tbl.delete;
 l_rul_object_code_tbl.delete;

 l_itm_to_price_tbl.delete;
 l_lse_id_tbl.delete;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('20: Contract Record PROCESSING ... ',2);
         okc_debug.Log('30: Contract Category     : '||p_category_code,2);
         okc_debug.Log('40: Contract Id           : '||chr_rec.id,2);
         okc_debug.Log('50: Contract Number       : '||chr_rec.contract_number,2);
         okc_debug.Log('60: Contract Number Mod   : '||chr_rec.contract_number_modifier,2);
      END IF;

    -- compute the new estimated amount for the contract

     l_user_estimated_amount := NVL(chr_rec.estimated_amount,0);
     l_estimated_amount := compute_estimated_amt(p_chr_id => chr_rec.id);

     IF (l_debug = 'Y') THEN
        okc_debug.Log('70: user_estimated_amount : '||l_user_estimated_amount,2);
        okc_debug.Log('80: estimated_amount : '||l_estimated_amount,2);
     END IF;

--???? asumming non configurator rows with only priced flag.
--make a heirarachy of lines with for each contract, going from top line to sub lines(leaf node last)
-- That means Top line will be level one. Parsing this way as then each line will come only once.
-- If the other way round that is leaf node first, top lines with more than one children will come
-- multiple times

   SELECT ROWID
   ,level
   ,id
   ,cle_id
   ,line_list_price
   ,price_unit
   ,price_level_ind
   ,price_list_id
   ,lse_id
   BULK COLLECT INTO
    l_line_rowid_tbl
   ,l_level_tbl
   ,l_line_id_tbl
   ,l_cle_id_tbl
   ,l_line_list_price_tbl
   ,l_price_unit_tbl
   ,l_priced_flag_tbl
   ,l_price_list_tbl
   ,l_lse_id_tbl
   FROM okc_k_lines_b
   CONNECT BY  (prior id = cle_id AND dnz_chr_id=chr_rec.id )
   START WITH chr_id = chr_rec.id;


   -- select the object code and id from rule 'PRE' defined at header and lines
   SELECT rul.object1_id1
   ,rul.jtot_object1_code
   ,rgp.chr_id
   ,rgp.cle_id
   BULK COLLECT INTO
    l_rul_pricelist_tbl
   ,l_rul_object_code_tbl
   ,l_rul_header_id_tbl
   ,l_rul_line_id_tbl
   FROM okc_rules_b rul,
        okc_rule_groups_b rgp
   WHERE rul.rgp_id = rgp.id
     AND rul.rule_information_category = 'PRE'
     AND rul.dnz_chr_id = chr_rec.id;

    -- skekkar
    -- for each line fetched get the item_to_price_yn flag
       FOR i IN NVL(l_lse_id_tbl.FIRST,0)..NVL(l_lse_id_tbl.LAST,-1)
       LOOP
        l_itm_to_price_tbl(i) := get_item_to_price_flag(l_lse_id_tbl(i));
       END LOOP;
    -- skekkar

    --it is possible to get too many rows for a header or a line
    --we will only pick up the first record fetched as we are not expecting
    --more than one pricing rule on header/line
    -- get the pricelist for the header

   l_price_list_id:=null;

   l:= l_rul_header_id_tbl.first;

   WHILE l IS NOT NULL LOOP -- look for header pricelist
     IF chr_rec.id = l_rul_header_id_tbl(l) THEN -- if id found
        l_price_list_id := l_rul_pricelist_tbl(l);
        l_obj_code      := l_rul_object_code_tbl(l);
        EXIT;
     END IF; --end if id found

     l:=l_rul_header_id_tbl.next(l);

   END LOOP; --end of loop for header pricelist

   -- if the object_code for the rule value is from okx_price and price_list_id is not null
   --we will store the current pricelist as header price list

   If l_price_list_id IS NOT NULL AND  l_obj_code = 'OKX_PRICE'  THEN --#If1
            l_hdr_price_list:= l_price_list_id;
   ELSE
            l_hdr_price_list:= null;

   END IF; --#end If1

  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: HEADER Price List Id : '||l_hdr_price_list ,2);
  END IF;


-- For each line defined for this contract, search for priced lines. The while loop below
-- will go through each line in the table looking for priced lines

    i:= l_line_id_tbl.FIRST;

    WHILE i IS NOT NULL LOOP  --#2 while

       -- If found a priced line, travel up the heirarchy for its parents
       IF l_priced_flag_tbl(i) = 'Y' THEN  -- #if2
           -- start traversing backwards from the priced line towards the top line
           j:=i;
           l_cle_id := l_line_id_tbl(j); -- make looking_for_cle_id (l_cle_id) same as current id

           -- initialize qty and added list price.l_line_list_price hold the list price added

           l_line_list_price:=0;  -- initailize priced line list price holder
           l_qty:=0;      -- initalize qty
           k:=null;      -- initialize k

           WHILE j IS NOT NULL LOOP --#3 while

              -- If found the line we are searching for
              IF l_cle_id = l_line_id_tbl(j) THEN --#if3
                   -- after we are done processing the found line, we will search for its parent
                   --so make the l_cle_id equal to its parent
                  l_cle_id:=l_cle_id_tbl(j);


                -----------get list price----------------------------------------------------
                -- If priced line then calculate list price by multiplying qty and list price
                  IF l_priced_flag_tbl(j) = 'Y'    THEN --#if4
                      k:=j;  -- holding the index of current priced line in question.needed if
                             -- if pricelist not found on priced line itself, then if found on
                             -- any of its parent, we will use that. hence keeping track of priced line

                      IF  l_price_unit_tbl(j) IS NOT NULL THEN  --#if5

                         SELECT NVL(number_of_items,0)
                           INTO l_qty
                           FROM okc_k_items
                          WHERE cle_id=l_line_id_tbl(j);

                         l_line_list_price_tbl(j):= NVL(l_qty,0) * NVL(l_price_unit_tbl(j),0);

                         IF (l_debug = 'Y') THEN
                            okc_debug.Log('150: Quantity Selected : '||l_qty,2);
                         END IF;

                      END IF; --#end if5 price_unit is not null

                      l_line_list_price := l_line_list_price_tbl(j);


                  -- else rollup the list price
                  ELSE  -- priced_flag is N

                      IF l_line_list_price IS NOT NULL THEN
                          l_line_list_price_tbl(j):=nvl(l_line_list_price_tbl(j),0)+ l_line_list_price;
                      END IF;

                  END IF; --#end if4 i.e l_priced_flag_tbl(j) = 'Y'

                  IF (l_debug = 'Y') THEN
                     okc_debug.Log('200: Line List Price : '||l_line_list_price,2);
                  END IF;

                  -----------end get list price---------------------------------------------------


                  -----------get pricelist--------------------------------------------------------
                  --get pricelist if not already there. it can be there if the line has alraedy been
                  -- parsed by another sub line
                  IF l_price_list_tbl(j) IS NULL THEN --#if6
                      -- search for the first pricelist for the current line
                     l:= l_rul_line_id_tbl.FIRST;

                     WHILE l IS NOT NULL LOOP --#4 while

                        IF l_line_id_tbl(j) = l_rul_line_id_tbl(l) AND
                           l_rul_object_code_tbl(l)='OKX_PRICE' THEN   --#if 8
                             l_price_list_tbl(j) := l_rul_pricelist_tbl(l);
                             EXIT;
                        END IF; --end If8

                        l:=l_rul_line_id_tbl.next(l);
                     END LOOP;  -- #4 end while

                  END IF; --#end If6

                  -- if the current line has apricelist and its priced child doesnot have
                  -- a pricelist, copy this pricelist to the priced child
                  IF  l_price_list_tbl(j) IS NOT NULL AND --# if9
                      k IS NOT NULL                   AND
                      l_price_list_tbl(k) IS NULL     THEN

                          l_price_list_tbl(k):= l_price_list_tbl(j);

                  END IF; --#end if9

                ------------end get pricelist-------------------------------------------------------

              END IF;  --#end if3



              --If already got the top line in the upward traversing from priced line, then come out of loop
              IF l_level_tbl(j) = 1 THEN --#if10

                -- if the priced line had no pricelist and none of its parents had
                -- a pricelist, copy the pricelist at header if there is one
                -- else copy the default price_list_id which is a parameter

                IF l_price_list_tbl(k) IS NULL THEN  --#if 11

                   IF l_hdr_price_list IS NOT NULL THEN -- skekkar
                     l_price_list_tbl(k) := l_hdr_price_list;
                   ELSE
                     l_price_list_tbl(k) := g_dflt_price_list_id;
                     g_k_price_list_id := g_dflt_price_list_id;
                     IF (l_debug = 'Y') THEN
                        okc_debug.Log('210: Using Default Price list Id ',2);
                     END IF;
                   END IF; -- skekkar

                END IF; --#end if11

                -- quit going up as already reached the top node
                EXIT;

              END IF; --#end If10

              j:= l_line_id_tbl.prior(j);

           END LOOP;  --#3 end while

           -- list price to be rolled up to header
           IF l_line_list_price IS NOT NULL THEN --#if12
             l_hdr_list_price:=nvl(l_hdr_list_price,0)+l_line_list_price;
           END IF; --#end if12

        END IF; --#end if2

       i:= l_line_id_tbl.next(i);

    END LOOP; --#2 end while


  -- forall changed lines

   IF l_line_id_tbl.count > 0 THEN --#if12

     FORALL j IN NVL(l_line_id_tbl.FIRST,0)..NVL(l_line_id_tbl.LAST,-1)
       UPDATE okc_k_lines_b
          SET object_version_number = object_version_number+1,
              last_updated_by = -1901903 ,--bug number
              last_update_date = sysdate ,
              line_list_price = l_line_list_price_tbl(j),
              price_list_id  = l_price_list_tbl(j),
              item_to_price_yn =  l_itm_to_price_tbl(j),
              program_application_id = fnd_global.prog_appl_id,
              program_id = fnd_global.conc_program_id,
              program_update_date = sysdate,
              request_id  = fnd_global.conc_request_id,
              pricing_date = sysdate
        WHERE rowid = l_line_rowid_tbl(j);

   END IF; --#end if12


   -- IF (l_hdr_list_price > 0 OR l_hdr_price_list IS NOT NULL ) THEN --#if13

   -- we will update the header even if the l_hdr_list_price and l_hdr_price_list are null
   -- we update the header with the estimated amt and user estimated amt

     UPDATE okc_k_headers_b
        SET object_version_number = object_version_number+1,
            last_updated_by = -1901903 ,--bug number
            last_update_date = sysdate,
            total_line_list_price = l_hdr_list_price,
            price_list_id = l_hdr_price_list,
            estimated_amount = NVL(l_estimated_amount,0),
            user_estimated_amount = NVL(l_user_estimated_amount,0),
            program_application_id = fnd_global.prog_appl_id,
            program_id = fnd_global.conc_program_id,
            program_update_date = sysdate,
            request_id  = fnd_global.conc_request_id,
            pricing_date = sysdate
      WHERE rowid = chr_rec.rowid;


      IF (l_debug = 'Y') THEN
         okc_debug.Log('400: Updated Header : '||chr_rec.contract_number,2);
      END IF;

      l_counter:=l_counter+1;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('410: Counter is :  '||l_counter,2);
      END IF;

   -- END IF; --#end if13

  -- check the difference between line_list_price and price_negotiated
  -- if there is a difference, create a manual adjustment transaction
     create_manual_adjustment
     (
      p_chr_id    => chr_rec.id
     );

  -- Insert into okc_qp_upgrade the chr_id we processed
   ins_contract_rec
   (
     p_category_code             =>  p_category_code,
     p_chr_id                    =>  chr_rec.id,
     p_contract_number           =>  chr_rec.contract_number,
     p_contract_number_modifier  =>  chr_rec.contract_number_modifier
   );


  IF l_counter >= 100 THEN --#if14

    IF (l_debug = 'Y') THEN
       okc_debug.Log('420: Commiting Work as Counter is :  '||l_counter,2);
    END IF;

    -- commit work
    commit;

    IF (l_debug = 'Y') THEN
       okc_debug.Log('430: Initializing Counter Again to 0',2);
    END IF;

    -- initialize counter
    l_counter := 0;

  END IF; --#end if14 i.e counter > 100


END LOOP; --#1 end for loop


-- commit work
   commit;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END start_category_upgrade;



/*----------------------------------------------------------------------------
        PROCEDURE ins_contract_rec
----------------------------------------------------------------------------*/
PROCEDURE ins_contract_rec
(
 p_category_code            IN   okc_subclasses_b.code%TYPE,
 p_chr_id                   IN   okc_k_headers_b.id%TYPE ,
 p_contract_number          IN   okc_k_headers_b.contract_number%TYPE,
 p_contract_number_modifier IN   okc_k_headers_b.contract_number_modifier%TYPE
)
IS
/*
  This procedure will insert record into okc_qp_upgrade table with line_type=CONTRACT
  We will insert a row for each contract that we upgrade.
  For contracts that have used default price list id at any of the line level, we will
  also store the default price list id for those contracts
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'ins_contract_rec';

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('20: Contract Record Inserting ... ',2);
         okc_debug.Log('30: Contract Category     : '||p_category_code,2);
         okc_debug.Log('40: Contract Id           : '||p_chr_id,2);
         okc_debug.Log('50: Contract Number       : '||p_contract_number,2);
         okc_debug.Log('60: Contract Number Mod   : '||p_contract_number_modifier,2);
         okc_debug.Log('70: Default Price List Id : '||g_k_price_list_id,2);
      END IF;

/*
       fnd_file.put_line(FND_FILE.LOG,'Processed Contract : '||p_contract_number||
               '  '|| p_contract_number_modifier||'  '||p_chr_id);
*/

       -- insert
       INSERT INTO okc_qp_upgrade
       (
         LINE_TYPE,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         COMPLETION_FLAG,
         SCS_CODE,
         CHR_ID,
         DFLT_PRICE_LIST_ID,
         REQUEST_ID,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN
       )
       VALUES
       (
         'CONTRACT',
         sysdate,
         sysdate,
         'Y',
         p_category_code,
         p_chr_id,
         g_k_price_list_id,
         fnd_global.conc_request_id,
         fnd_global.user_id,
         fnd_global.user_id,
         fnd_global.conc_login_id
       );


   -- initialize the g_k_price_list_id
     g_k_price_list_id := '';


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END ins_contract_rec;


/*----------------------------------------------------------------------------
        PROCEDURE call_qp_upgrade
----------------------------------------------------------------------------*/
PROCEDURE  call_qp_upgrade
(
 p_category_code          IN   okc_subclasses_b.code%TYPE
)
IS
/*
  This procedure will do the following
  1. Check if the upgrade already done successfully, if Yes then abort
  2. Insert the Summary Record
  3. Call the start_category_upgrade with the p_category_code
  4. Update the category record as complete after upgrade
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'call_qp_upgrade';

CURSOR csr_summary_rec IS
SELECT *
FROM okc_qp_upgrade
WHERE line_type='SUMMARY'
  AND completion_flag = 'Y';

-- category cursor for all/ specific categories in OKC and OKO
CURSOR csr_category IS
SELECT scs.code
FROM okc_subclasses_b scs,
     okc_classes_b cs
WHERE scs.cls_code = cs.code
  AND cs.application_id IN (510,871)
  AND scs.code = NVL(p_category_code,scs.code) ;


l_code            okc_subclasses_b.code%TYPE;
l_qp_upgrade_rec  okc_qp_upgrade%ROWTYPE;


BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;
/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'    call_qp_upgrade                               ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

  IF (l_debug = 'Y') THEN
     okc_debug.Log('20: p_category_code :  '||p_category_code,2);
  END IF;

  -- check if the upgrade is already done, if Y then abort
  OPEN csr_summary_rec;
    FETCH csr_summary_rec INTO l_qp_upgrade_rec;
     IF csr_summary_rec%NOTFOUND THEN
        -- start processing here

             IF (l_debug = 'Y') THEN
                okc_debug.Log('60: Category Id is : '||p_category_code,2);
             END IF;

         -- insert the summary record
            ins_summary_rec;

         -- Start Process for each category
          OPEN csr_category;
           LOOP
            FETCH csr_category INTO l_code;
            EXIT WHEN csr_category%NOTFOUND;

             -- insert the Category record and start the upgrade
             ins_category_rec
             (
              p_category_code    =>   l_code
             );

           END LOOP;  -- for each category
          CLOSE csr_category;


     ELSE  -- csr_summary_rec FOUND, upgrade already done abort
        IF (l_debug = 'Y') THEN
           okc_debug.Log('500: Aborting as the Upgrade is already Done ... ',2);
        END IF;
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_message.set_name('OKC','OKC_QP_ALREADY_DONE');
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
     END IF;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END call_qp_upgrade;



/*----------------------------------------------------------------------------
        PROCEDURE upd_category_rec
----------------------------------------------------------------------------*/
PROCEDURE upd_category_rec
(
 p_category_code  IN   okc_subclasses_b.code%TYPE,
 p_status         IN   varchar2
)
IS
/*
  This procedure will update the category record currently processed as complete

*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'upd_category_rec';

CURSOR csr_category_rec IS
SELECT *
FROM okc_qp_upgrade
WHERE line_type = 'CATEGORY'
  AND scs_code = p_category_code
  AND completion_flag = 'P'
FOR UPDATE OF completion_flag;

l_qp_upgrade_rec     okc_qp_upgrade%ROWTYPE;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'    upd_category_rec                              ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

   OPEN csr_category_rec;
     LOOP
    FETCH csr_category_rec INTO l_qp_upgrade_rec;
     IF (l_debug = 'Y') THEN
        okc_debug.set_trace_off;
     END IF;
    EXIT WHEN csr_category_rec%NOTFOUND;
       UPDATE okc_qp_upgrade
          SET completion_flag = p_status,
              last_update_date = sysdate
       WHERE CURRENT OF csr_category_rec;
     END LOOP;
   CLOSE csr_category_rec;
   IF (l_debug = 'Y') THEN
      okc_debug.set_trace_on;
   END IF;
   -- commit work
   commit;

   -- initialize the global variable as this category id done and we move to next
      g_category_code  := '' ;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
         IF (l_debug = 'Y') THEN
            okc_debug.set_trace_on;
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
         END IF;
        fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
        fnd_message.set_token('ROUTINE',l_proc);
        fnd_message.set_token('REASON',SQLERRM);
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        raise g_error_exception;
END upd_category_rec;


/*----------------------------------------------------------------------------
        PROCEDURE upd_summary_rec
----------------------------------------------------------------------------*/
PROCEDURE upd_summary_rec
IS
/*
  This Procedure will be called when the user wants to enable the QP Profile.
  It will check if all the Categories have been successfully completed.
  If No, it will abort
  If Yes, it will update the SUMMARY record as done  and enable the QP Profile
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'upd_summary_rec';
l_total_categories           number(9);
l_categories_done            number(9);

CURSOR csr_total_categories IS
SELECT COUNT(scs.code)
FROM okc_subclasses_b scs, okc_classes_b cs
WHERE scs.cls_code = cs.code
  AND cs.application_id IN ( 510, 871 );

CURSOR csr_categories_done IS
SELECT COUNT(scs_code)
FROM okc_qp_upgrade
WHERE line_type='CATEGORY'
  and completion_flag = 'Y';

CURSOR csr_summary_rec IS
SELECT *
FROM okc_qp_upgrade
WHERE line_type='SUMMARY'
  AND completion_flag= 'N'
FOR UPDATE OF completion_flag;

l_qp_upgrade_rec   okc_qp_upgrade%ROWTYPE;
l_prof_val         varchar2(10);

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'        upd_summary_rec                           ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

   OPEN csr_total_categories;
     FETCH csr_total_categories INTO  l_total_categories;
   CLOSE csr_total_categories;

   IF (l_debug = 'Y') THEN
      okc_debug.Log('50: Total Categories : '||l_total_categories,2);
   END IF;
   fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
   fnd_message.set_name('OKC','OKC_TOT_CONTRACT_CATS');
   fnd_message.set_token('TOTCATS',l_total_categories);
   fnd_file.put_line(FND_FILE.LOG,fnd_message.get);

   OPEN csr_categories_done;
     FETCH csr_categories_done INTO  l_categories_done;
   CLOSE csr_categories_done;

   IF (l_debug = 'Y') THEN
      okc_debug.Log('100: Categories Upgraded : '||l_categories_done,2);
   END IF;
   fnd_message.set_name('OKC','OKC_TOT_CATEGORIES_UPG');
   fnd_message.set_token('TOTUPG',l_categories_done);
   fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
   fnd_file.put_line(FND_FILE.LOG,'  ');
   fnd_file.put_line(FND_FILE.LOG,'  ');
   fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');

   IF NVL(l_total_categories,0) <> NVL(l_categories_done,0) THEN
      -- cannot enable profile as all categories are not processed
      IF (l_debug = 'Y') THEN
         okc_debug.Log('200: cannot enable profile as all categories are not processed ',2);
      END IF;
      fnd_message.set_name('OKC','OKC_QP_PROFILE_FAIL');
      fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
      fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'  ');
   ELSE
      -- update the SUMMARY Record
      OPEN csr_summary_rec;
        IF (l_debug = 'Y') THEN
           okc_debug.set_trace_off;
        END IF;
         LOOP
          FETCH csr_summary_rec INTO l_qp_upgrade_rec;
          EXIT WHEN csr_summary_rec%NOTFOUND;
            UPDATE okc_qp_upgrade
               SET completion_flag ='Y',
                   last_update_date = sysdate
             WHERE CURRENT OF csr_summary_rec;
        END LOOP;
      CLOSE csr_summary_rec;
   IF (l_debug = 'Y') THEN
      okc_debug.set_trace_on;
   END IF;
      -- commit work
       commit;

      -- enable the Profile Option OKC_ADVANCED_PRICING to 'Y'
      -- check the current value of OKC_ADVANCED_PRICING
        l_prof_val := fnd_profile.value('OKC_ADVANCED_PRICING');

        IF (l_debug = 'Y') THEN
           okc_debug.Log('400: Current OKC_ADVANCED_PRICING Profile Value :  '||l_prof_val,2);
        END IF;

        IF NVL(l_prof_val,'N') = 'N' THEN
          -- set profile to Y
          IF (l_debug = 'Y') THEN
             okc_debug.Log('450: Setting OKC_ADVANCED_PRICING to Y ',2);
          END IF;

          -- check if profile successfully set to Y
           IF fnd_profile.save('OKC_ADVANCED_PRICING', 'Y', 'SITE')  THEN
             -- commit changes
             commit;
             IF (l_debug = 'Y') THEN
                okc_debug.Log('500: OKC_ADVANCED_PRICING Successfully Set to Y',2);
             END IF;
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
             fnd_message.set_name('OKC','OKC_QP_PROFILE_SUCCESS');
             fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
             fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');
           ELSE
             -- give error here
             IF (l_debug = 'Y') THEN
                okc_debug.Log('600: Error Setting OKC_ADVANCED_PRICING to Y');
             END IF;
             fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
             fnd_message.set_token('ROUTINE',l_proc);
             fnd_message.set_token('REASON',SQLERRM);
             fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
             APP_EXCEPTION.RAISE_EXCEPTION;
           END IF; -- for setting profile



        END IF;  -- l_prof_val is N


   END IF;  -- l_total_categories <> l_categories_done

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.set_trace_on;
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     raise;
END  upd_summary_rec;


/*----------------------------------------------------------------------------
        PROCEDURE process_report
----------------------------------------------------------------------------*/
PROCEDURE process_report
IS
/*
  This Procedure will process the upgrade_status_rpt
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'process_report';

BEGIN


  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'       process_report                             ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

     IF (l_debug = 'Y') THEN
        okc_debug.Log('50: Calling upgrade_status_rpt ',2);
     END IF;
     fnd_file.put_line(FND_FILE.LOG,'Processing Upgrade Status report');
     upgrade_status_rpt;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     raise;
END process_report;


/*----------------------------------------------------------------------------
        PROCEDURE upgrade_status_rpt
----------------------------------------------------------------------------*/
PROCEDURE upgrade_status_rpt
IS
/*
  This Procedure will be report the upgrade status.
  It will list the the following :
  1. Categories that have been successfully upgraded.
  2. Categories that have not been successfully or completely upgraded.
  3. Categories that have never been upgraded.

*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'upgrade_status_rpt';

l_star_line   varchar2(120) := '*************************************************************************************';
l_dash_line   varchar2(120) := '-------------------------------------------------------------------------------------';
l_equl_line   varchar2(120) := '=====================================================================================';
l_space           varchar2(80) := '  ';

l_rpt_title1 varchar2(120) := '             LIST OF CATEGORIES SUCCESSFULLY UPGRADED : ';
l_rpt_title2 varchar2(120) := '             LIST OF CATEGORIES PARTIALLY UPGRADED : ';
l_rpt_title3 varchar2(120) := '             LIST OF CATEGORIES NOT UPGRADED : ';

-- l_cat_comp_header varchar2(120) := 'Category Name                            Upgrade Start  Upgrade End ';
l_cat_comp_header varchar2(120) := 'Category Name';
l_cat_incomp_header varchar2(120) := 'Category Name';
l_category_name   varchar2(80);
l_start_date      date;
l_end_date        date;

CURSOR category_compeleted_csr IS
SELECT RPAD(scs.meaning,40),
       RPAD(qp.CREATION_DATE,13),
       qp.LAST_UPDATE_DATE
FROM  okc_subclasses_v scs, okc_qp_upgrade qp
WHERE qp.scs_code = scs.code
  AND qp.line_type = 'CATEGORY'
  AND qp.completion_flag = 'Y'
ORDER BY scs.meaning;

CURSOR category_incompeleted_csr IS
SELECT scs.meaning
FROM  okc_subclasses_v scs, okc_qp_upgrade qp
WHERE qp.scs_code = scs.code
  AND qp.line_type = 'CATEGORY'
  AND qp.completion_flag = 'N'
ORDER BY scs.meaning;

CURSOR category_pending_csr IS
SELECT scs.meaning
FROM  okc_subclasses_v scs, okc_classes_b cs
WHERE scs.cls_code = cs.code
  AND cs.application_id IN (510,871)
  AND scs.code NOT IN (
                        SELECT scs_code
                        FROM okc_qp_upgrade
                        WHERE line_type='CATEGORY'
                      )
ORDER BY scs.meaning;

BEGIN


  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

/*
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'           upgrade_status_rpt                     ');
  fnd_file.put_line(FND_FILE.LOG,' ================================================ ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');
*/

  fnd_file.put_line(FND_FILE.OUTPUT,l_equl_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,'          UPGRADE STATUS REPORT  ');
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_equl_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);

  -- Successful Categories

  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_rpt_title1);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_cat_comp_header);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);

  OPEN category_compeleted_csr;
    LOOP
      FETCH category_compeleted_csr INTO l_category_name, l_start_date, l_end_date;
      EXIT WHEN category_compeleted_csr%NOTFOUND;
        fnd_file.put_line(FND_FILE.OUTPUT, l_category_name);
    END LOOP;
  CLOSE category_compeleted_csr;

  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);

  -- blank lines
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  -- end blank lines

  -- Incomplete Categories

  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_rpt_title2);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_cat_incomp_header);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);

  OPEN category_incompeleted_csr;
    LOOP
      FETCH category_incompeleted_csr INTO l_category_name;
      EXIT WHEN category_incompeleted_csr%NOTFOUND;
        fnd_file.put_line(FND_FILE.OUTPUT, l_category_name);
    END LOOP;
  CLOSE category_incompeleted_csr;

  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);

  -- blank lines
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  -- end blank lines

  -- Categories not upgraded
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_rpt_title3);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_cat_incomp_header);
  fnd_file.put_line(FND_FILE.OUTPUT,l_dash_line);

  OPEN category_pending_csr;
    LOOP
      FETCH category_pending_csr INTO l_category_name;
      EXIT WHEN category_pending_csr%NOTFOUND;
        fnd_file.put_line(FND_FILE.OUTPUT, l_category_name);
    END LOOP;
  CLOSE category_pending_csr;

  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_star_line);

  -- blank lines
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  -- end blank lines

  fnd_file.put_line(FND_FILE.OUTPUT,l_equl_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,'          END UPGRADE STATUS REPORT  ');
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);
  fnd_file.put_line(FND_FILE.OUTPUT,l_equl_line);
  fnd_file.put_line(FND_FILE.OUTPUT,l_space);



  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     raise;
END upgrade_status_rpt;

/*----------------------------------------------------------------------------
        FUNCTION check_qp_profile
----------------------------------------------------------------------------*/
FUNCTION check_qp_profile
RETURN VARCHAR2
IS
/*
  This Function will check the OKC_ADVANCED_PRICING Profile Value before starting
  conc. pgm and will abort if the OKC_ADVANCED_PRICING Profile Value is Y
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'check_qp_profile';
l_prof_val                   varchar2(10):= 'N';

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- check the current value of OKC_ADVANCED_PRICING
     l_prof_val := fnd_profile.value('OKC_ADVANCED_PRICING');

     IF (l_debug = 'Y') THEN
        okc_debug.Log('100: Current OKC_ADVANCED_PRICING Profile Value :  '||l_prof_val,2);
     END IF;

     IF NVL(l_prof_val,'N') = 'Y' THEN
     -- upgrade already done, abort
        IF (l_debug = 'Y') THEN
           okc_debug.Log('200: Aborting as the Upgrade is already Done ... ',2);
        END IF;
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
        fnd_message.set_name('OKC','OKC_QP_ALREADY_DONE');
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
     END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  RETURN l_prof_val;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     RETURN l_prof_val;
END check_qp_profile;

/*----------------------------------------------------------------------------
        FUNCTION compute_estimated_amt
----------------------------------------------------------------------------*/
FUNCTION compute_estimated_amt
(
 p_chr_id    IN okc_k_headers_b.id%TYPE
)
RETURN number
IS
/*
  This will then compute the estimated_amount as sum of price_negotiated for all lines at
  level 1 for the contract
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'compute_estimated_amt';
l_estimated_amt              number := 0;

CURSOR csr_estimated_amt IS
SELECT SUM(NVL(price_negotiated,0))
FROM okc_k_lines_b
WHERE chr_id = p_chr_id;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

      OPEN csr_estimated_amt;
        FETCH csr_estimated_amt INTO l_estimated_amt;
      CLOSE csr_estimated_amt;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('100: New Estimated Amount : '||NVL(l_estimated_amt,0),2);
      END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  RETURN NVL(l_estimated_amt,0);

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     RETURN NVL(l_estimated_amt,0);
     raise;
END compute_estimated_amt;



/*----------------------------------------------------------------------------
        PROCEDURE create_manual_adjustment
----------------------------------------------------------------------------*/
PROCEDURE create_manual_adjustment
(
 p_chr_id    IN okc_k_headers_b.id%TYPE
)
IS
/*
  This procedure will check if there is any difference between line_list_price and
  price_negotiated for priced lines and if yes it will create a manual adjustment
  transaction
  Assumption : There is a Modifier created with name OKC_QP_UPGRADE
  This Modifier has lines  : Discount and Surcharge.
  We pick up the Surcharge Line if price_negotiated > line_list_price
  We pick up the Discount  Line if price_negotiated < line_list_price
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'create_manual_adjustment';

CURSOR csr_man_adj IS
SELECT *
FROM okc_k_lines_b
WHERE dnz_chr_id = p_chr_id
  AND NVL(price_level_ind,'N') = 'Y'
  AND NVL(line_list_price,0) <> NVL(price_negotiated,0);

CURSOR csr_list_lines(p_list_line_type_code IN VARCHAR2) IS
SELECT *
FROM qp_list_lines
WHERE list_line_type_code = p_list_line_type_code
  AND list_header_id IN (
                          SELECT list_header_id
                          FROM qp_list_headers
                          WHERE name = 'OKC_QP_UPGRADE'
                        );

l_k_lines_rec            okc_k_lines_b%ROWTYPE;
l_qp_list_lines_rec      qp_list_lines%ROWTYPE;
l_adj_amt                number;
l_id                     number;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
     okc_debug.Log('50: p_chr_id : '||p_chr_id,2);
  END IF;

  OPEN csr_man_adj;
    LOOP
      FETCH csr_man_adj INTO l_k_lines_rec;
      EXIT WHEN csr_man_adj%NOTFOUND;

         -- create man adj here
         l_adj_amt := NVL(l_k_lines_rec.line_list_price,0) - NVL(l_k_lines_rec.price_negotiated,0) ;
         IF (l_debug = 'Y') THEN
            okc_debug.Log('100: Adjusted Amt : '||l_adj_amt,2);
         END IF;

         IF l_adj_amt > 0 THEN
           -- this is discount as list pr > negotiated pr
           OPEN csr_list_lines(p_list_line_type_code => 'DIS');
                FETCH csr_list_lines INTO l_qp_list_lines_rec;
         ELSE
           -- this is surcharge
           OPEN csr_list_lines(p_list_line_type_code => 'SUR');
                FETCH csr_list_lines INTO l_qp_list_lines_rec;
         END IF;

         -- generate Primary Key
         l_id := get_seq_id;
         IF (l_debug = 'Y') THEN
            okc_debug.Log('200: Primary Key : '||l_id,2);
         END IF;

         -- insert adj into okc_price_adjustments
         INSERT INTO okc_price_adjustments
         (
          ID,
          CHR_ID,
          CLE_ID,
          ACCRUAL_CONVERSION_RATE,
          ACCRUAL_FLAG,
          ADJUSTED_AMOUNT,
          APPLIED_FLAG,
          ARITHMETIC_OPERATOR,
          AUTOMATIC_FLAG,
          BENEFIT_QTY,
          BENEFIT_UOM_CODE,
          CHARGE_SUBTYPE_CODE,
          CHARGE_TYPE_CODE ,
          EXPIRATION_DATE ,
          INCLUDE_ON_RETURNS_FLAG ,
          LIST_HEADER_ID ,
          LIST_LINE_ID ,
          LIST_LINE_NO ,
          LIST_LINE_TYPE_CODE ,
          MODIFIER_LEVEL_CODE ,
          MODIFIER_MECHANISM_TYPE_CODE ,
          OPERAND ,
          PRICE_BREAK_TYPE_CODE ,
          PRICING_GROUP_SEQUENCE ,
          PRICING_PHASE_ID ,
          PRORATION_TYPE_CODE ,
          REBATE_TRANSACTION_TYPE_CODE ,
          RANGE_BREAK_QUANTITY ,
          SOURCE_SYSTEM_CODE ,
          SUBSTITUTION_ATTRIBUTE ,
          UPDATE_ALLOWED ,
          UPDATED_FLAG ,
          OBJECT_VERSION_NUMBER ,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE
         )
         VALUES
         (
          l_id , -- ID
          p_chr_id, -- CHR_ID
          l_k_lines_rec.id, -- CLE_ID
          l_qp_list_lines_rec.accrual_conversion_rate, -- ACCRUAL_CONVERSION_RATE
          l_qp_list_lines_rec.accrual_flag,-- ACCRUAL_FLAG
          -1*(l_adj_amt),-- ADJUSTED_AMOUNT
          'Y',-- APPLIED_FLAG
          l_qp_list_lines_rec.arithmetic_operator, -- ARITHMETIC_OPERATOR
          l_qp_list_lines_rec.automatic_flag,-- AUTOMATIC_FLAG
          l_qp_list_lines_rec.benefit_qty , -- BENEFIT_QTY
          l_qp_list_lines_rec.benefit_uom_code , -- BENEFIT_UOM_CODE
          l_qp_list_lines_rec.charge_subtype_code , -- CHARGE_SUBTYPE_CODE
          l_qp_list_lines_rec.charge_type_code  , -- CHARGE_TYPE_CODE
          l_qp_list_lines_rec.expiration_date  , -- EXPIRATION_DATE
          l_qp_list_lines_rec.include_on_returns_flag  , -- INCLUDE_ON_RETURNS_FLAG
          l_qp_list_lines_rec.list_header_id  , -- LIST_HEADER_ID
          l_qp_list_lines_rec.list_line_id  , -- LIST_LINE_ID
          l_qp_list_lines_rec.list_line_no  , -- LIST_LINE_NO
          l_qp_list_lines_rec.list_line_type_code  , -- LIST_LINE_TYPE_CODE
          l_qp_list_lines_rec.modifier_level_code  , -- MODIFIER_LEVEL_CODE
          'DLT'  , -- MODIFIER_MECHANISM_TYPE_CODE
          l_adj_amt  , -- OPERAND  this is reverse of ADJUSTED_AMOUNT
          l_qp_list_lines_rec.price_break_type_code  , -- PRICE_BREAK_TYPE_CODE
          l_qp_list_lines_rec.pricing_group_sequence  , -- PRICING_GROUP_SEQUENCE
          l_qp_list_lines_rec.pricing_phase_id  , -- PRICING_PHASE_ID
          l_qp_list_lines_rec.proration_type_code  , -- PRORATION_TYPE_CODE
          l_qp_list_lines_rec.rebate_transaction_type_code  , -- REBATE_TRANSACTION_TYPE_CODE
          NULL  , -- RANGE_BREAK_QUANTITY
          NULL  , -- SOURCE_SYSTEM_CODE
          l_qp_list_lines_rec.substitution_attribute  , -- SUBSTITUTION_ATTRIBUTE
          l_qp_list_lines_rec.override_flag  , -- UPDATE_ALLOWED
          'Y'  , -- UPDATED_FLAG
          1, -- OBJECT_VERSION_NUMBER
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate
         );

       CLOSE csr_list_lines; -- close the list line cursor

    END LOOP;
  CLOSE csr_man_adj;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     raise;
END create_manual_adjustment;


/*----------------------------------------------------------------------------
        FUNCTION  check_modifier
----------------------------------------------------------------------------*/
FUNCTION check_modifier RETURN varchar2
IS
/*
  This function will check if there is a Modifier created with name OKC_QP_UPGRADE
  Returns Y if Modifier defined
  Returns N if Modifier not defined
  Assumption : Pre req for upgrade that  Modifier created with name OKC_QP_UPGRADE
*/

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'check_modifier';
l_status                     varchar2(10) := 'N';
l_qp_list_lines_rec          qp_list_lines%ROWTYPE;

CURSOR csr_list_lines IS
SELECT *
FROM qp_list_lines
WHERE list_header_id IN (
                          SELECT list_header_id
                          FROM qp_list_headers
                          WHERE name = 'OKC_QP_UPGRADE'
                        );

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OPEN csr_list_lines;
    -- only one line for the modifier OKC_QP_UPGRADE
    FETCH csr_list_lines INTO l_qp_list_lines_rec;
      -- check if the above Modifier is defined else give message
      IF csr_list_lines%NOTFOUND THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('100: Aborting as the Modifier OKC_QP_UPGRADE is not defined  ',2);
        END IF;
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
        fnd_message.set_name('OKC','OKC_MOD_NOT_DEFINED');
        fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
        fnd_file.put_line(FND_FILE.LOG,' *********************************************** ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'  ');
        l_status := 'N';
      ELSE
       -- modifier is defined
        l_status := 'Y';
      END IF;

  CLOSE csr_list_lines;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  RETURN l_status;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     RETURN l_status;
END check_modifier;

/*----------------------------------------------------------------------------
        FUNCTION  get_seq_id
----------------------------------------------------------------------------*/
FUNCTION get_seq_id RETURN NUMBER
IS

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'get_seq_id';
l_id                         number;

BEGIN


  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  RETURN(okc_p_util.raw_to_number(sys_guid()));

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     RETURN l_id;
END get_seq_id;


/*----------------------------------------------------------------------------
        FUNCTION  get_item_to_price_flag
----------------------------------------------------------------------------*/
FUNCTION get_item_to_price_flag
(p_lse_id IN NUMBER )
RETURN VARCHAR2
IS

-- local variables and cursors

l_proc                       varchar2(72) := g_package||'get_item_to_price_flag';
l_flag                       varchar2(10) := 'N';

CURSOR csr_item_to_price_flag IS
SELECT NVL(item_to_price_yn,'N')
FROM okc_line_styles_b
WHERE id = p_lse_id;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OPEN csr_item_to_price_flag;
    FETCH csr_item_to_price_flag INTO l_flag;
  CLOSE csr_item_to_price_flag;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: l_flag : '||l_flag,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  RETURN l_flag;

EXCEPTION
  WHEN others THEN
     IF (l_debug = 'Y') THEN
        okc_debug.Log('2000: Leaving ',2);
        okc_debug.Reset_Indentation;
     END IF;
     fnd_message.set_name('OKC','OKC_CATASTROPHIC_ERROR');
     fnd_message.set_token('ROUTINE',l_proc);
     fnd_message.set_token('REASON',SQLERRM);
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     RETURN l_flag;
END get_item_to_price_flag;




END OKC_QP_UPGRADE_PUB; -- Package Body OKC_QP_UPGRADE_PUB

/
