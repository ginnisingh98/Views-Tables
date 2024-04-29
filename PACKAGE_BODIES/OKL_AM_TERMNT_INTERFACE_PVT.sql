--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_INTERFACE_PVT" AS
/* $Header: OKLRTIFB.pls 120.9.12010000.3 2009/06/15 21:51:55 sechawla ship $ */

subtype quot_rec_type IS OKL_TRX_QUOTES_PUB.qtev_rec_type;
subtype assn_tbl_type IS OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type;
subtype tqlv_tbl_type IS OKL_TXL_QUOTE_LINES_PUB.tqlv_tbl_type;
subtype qld_tbl_type  IS OKL_AM_TERMNT_QUOTE_PUB.qte_ln_dtl_tbl;
subtype qpyv_tbl_type IS OKL_QUOTE_PARTIES_PUB.qpyv_tbl_type;
subtype tmgv_rec_type IS OKL_TMG_PVT.tmgv_rec_type;

TYPE msg_rec_type IS RECORD (
     msg_text             VARCHAR2(2000));

TYPE msg_tbl_type IS TABLE OF msg_rec_type
        INDEX BY BINARY_INTEGER;
-- this record is used to store the messages for a particular line in the log
TYPE log_msg_rec_type IS RECORD (
     transaction_number   OKL_TERMNT_INTERFACE.transaction_number%TYPE,
     msg_text             VARCHAR2(2000));

TYPE log_msg_tbl_type IS TABLE OF log_msg_rec_type
        INDEX BY BINARY_INTEGER;
-- this record is used to store the header inforamtion for particular line in the log
TYPE log_rec_type IS RECORD (
     transaction_number   OKL_TERMNT_INTERFACE.transaction_number%TYPE,
     contract_number      OKL_TERMNT_INTERFACE.contract_number%TYPE,
     asset_number         OKL_TERMNT_INTERFACE.asset_number%TYPE,
     date_effective_from  OKL_TERMNT_INTERFACE.date_effective_from%TYPE,
     quote_type           OKL_TERMNT_INTERFACE.quote_type_code%TYPE,
     quote_reason         OKL_TERMNT_INTERFACE.quote_reason_code%TYPE,
     quote_number         NUMBER);

TYPE log_tbl_type IS TABLE OF log_rec_type
        INDEX BY BINARY_INTEGER;

              val_log_tbl        log_tbl_type;
              pro_log_tbl        log_tbl_type;
              err_log_tbl        log_tbl_type;

              val_msg_tbl        log_msg_tbl_type;
              pro_msg_tbl        log_msg_tbl_type;
              err_msg_tbl        log_msg_tbl_type;

  -- PAGARG 23-Feb-05 Declared a table to messages from error stack
  TYPE error_message_type IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

  /**************************************************************************/
  -- Start of comments
  --
  -- Procedure Name  : get_error_message
  -- Description     : This procedure unwinds the error messages from stack
  -- Business Rules  :
  -- Parameters      : p_all_message
  -- Version         : 1.0
  -- History         : 23-Feb-2005 PAGARG Created
  -- End of comments
  PROCEDURE get_error_message(p_all_message OUT NOCOPY error_message_type)
  IS
    l_msg_index_out   NUMBER;
    l_data            VARCHAR2(2000);
    l_counter         NUMBER := 0;
  BEGIN
    FOR l_counter IN 1..fnd_msg_pub.count_msg
    LOOP
      fnd_msg_pub.get
        (p_data          => l_data,
         p_msg_index_out => l_msg_index_out,
         p_encoded       => FND_API.G_FALSE,
         p_msg_index     => l_counter);
      p_all_message(l_counter) := l_data;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END get_error_message;
  /**************************************************************************/

  -- Start of comments
  --
  -- Procedure Name  : log_messages
  -- Description     : This procedure logs the messages to concuurent log, output
  -- Business Rules  :
  -- Parameters      : log_msg_flag, p_tif_rec, msg_text
  -- Version         : 1.0
  -- History         : 18-FEB-03 SPILLAIP Created
  --                 : 27-MAR-03 RABHUPAT modified
  --                 : 22-JUL-03 RABHUPAT modified
  -- End of comments

  -- Y for putting in log and output,V for not processed, E for processed with Error,P for processed,O for output

    PROCEDURE log_messages(log_msg_flag             IN VARCHAR2     DEFAULT '',
                           p_transaction_number     IN VARCHAR2     DEFAULT '',
                           p_contract_number        IN VARCHAR2     DEFAULT '',
                           p_asset_number           IN VARCHAR2     DEFAULT '',
                           p_date_effective         IN DATE         DEFAULT OKC_API.G_MISS_DATE,
                           p_quote_type             IN VARCHAR2     DEFAULT '',
                           p_quote_reason           IN VARCHAR2     DEFAULT '',
                           p_quote_number           IN NUMBER       DEFAULT OKC_API.G_MISS_NUM,
                           msg_tbl                  IN msg_tbl_type
                           ) IS
              val_count          NUMBER := 0;
              err_count          NUMBER := 0;
              pro_count          NUMBER := 0;

              val_msg_count      NUMBER := 0;
              err_msg_count      NUMBER := 0;
              pro_msg_count      NUMBER := 0;

              tot_count          NUMBER := 0;
              count_msg          NUMBER := 1;
              l_org_id           NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
              l_org_name         VARCHAR2(40);
              l_quote_type       VARCHAR2(100);
              l_quote_reason     VARCHAR2(100);


              -- cursor to retrieve operating_units
              CURSOR org_csr (l_org_id IN NUMBER) IS
              SELECT name
              FROM   hr_operating_units
              WHERE  organization_id = l_org_id;

              /* gets the meaning for each quote_type_code from FND_LOOKUPS*/
              CURSOR get_quote_type_meaning_csr(p_quote_type IN VARCHAR2) IS
              SELECT meaning
              FROM FND_LOOKUPS
              WHERE lookup_code = p_quote_type AND lookup_type = 'OKL_QUOTE_TYPE' AND enabled_flag = 'Y';

              /* gets the meaning for each quote_reason from FND_LOOKUPS*/
              CURSOR get_quote_reason_meaning_csr(p_quote_reason IN VARCHAR2) IS
              SELECT meaning
              FROM FND_LOOKUPS
              WHERE lookup_code = p_quote_reason AND lookup_type = 'OKL_QUOTE_REASON' AND enabled_flag = 'Y';

    BEGIN
       -- transactions which are not processed due to errors will be inserted in to val_msg_tbl
       IF(log_msg_flag = 'V') THEN
          val_count                                  := val_log_tbl.COUNT + 1;
          val_log_tbl(val_count).transaction_number  := p_transaction_number;
          val_log_tbl(val_count).contract_number     := p_contract_number;
          val_log_tbl(val_count).asset_number        := p_asset_number;
          val_log_tbl(val_count).date_effective_from := p_date_effective;
          val_log_tbl(val_count).quote_type          := p_quote_type;
          val_log_tbl(val_count).quote_reason        := p_quote_reason;

          IF(msg_tbl.COUNT > 0) THEN
            FOR i IN msg_tbl.FIRST..msg_tbl.LAST
            LOOP
                val_msg_count                                  := val_msg_tbl.COUNT + 1;
                val_msg_tbl(val_msg_count).transaction_number  := p_transaction_number;
                val_msg_tbl(val_msg_count).msg_text            := msg_tbl(i).msg_text;
            END LOOP;
          END IF;
       -- transactions which are processed with errors will be inserted in to err_msg_tbl
       ELSIF(log_msg_flag = 'E') THEN
             err_count                                  := err_log_tbl.COUNT + 1;
             err_log_tbl(err_count).transaction_number  := p_transaction_number;
             err_log_tbl(err_count).contract_number     := p_contract_number;
             err_log_tbl(err_count).asset_number        := p_asset_number;
             err_log_tbl(err_count).date_effective_from := p_date_effective;
             err_log_tbl(err_count).quote_type          := p_quote_type;
             err_log_tbl(err_count).quote_reason        := p_quote_reason;
             err_log_tbl(err_count).quote_number        := p_quote_number;

             IF(msg_tbl.COUNT > 0) THEN
                FOR i IN msg_tbl.FIRST..msg_tbl.LAST
                LOOP
                    err_msg_count                                  := err_msg_tbl.COUNT + 1;
                    err_msg_tbl(err_msg_count).transaction_number  := p_transaction_number;
                    err_msg_tbl(err_msg_count).msg_text            := msg_tbl(i).msg_text;
                END LOOP;
             END IF;
       -- transactions which are processed will be inserted in to pro_msg_tbl
       ELSIF(log_msg_flag = 'P') THEN
             pro_count                                  := pro_log_tbl.COUNT + 1;
             pro_log_tbl(pro_count).transaction_number  := p_transaction_number;
             pro_log_tbl(pro_count).contract_number     := p_contract_number;
             pro_log_tbl(pro_count).asset_number        := p_asset_number;
             pro_log_tbl(pro_count).date_effective_from := p_date_effective;
             pro_log_tbl(pro_count).quote_type          := p_quote_type;
             pro_log_tbl(pro_count).quote_reason        := p_quote_reason;
             pro_log_tbl(pro_count).quote_number        := p_quote_number;

       END IF;
       -- enter the messages in to LOG
       IF(log_msg_flag = 'Y') THEN
          -- cursor to retrieve operating unit name
           FOR org_rec IN org_csr (l_org_id) LOOP
               l_org_name := org_rec.name;
           END LOOP;
           tot_count := p_quote_number;
           val_count := val_log_tbl.COUNT;
           err_count := err_log_tbl.COUNT;
           pro_count := tot_count-(val_count+err_count);
           -- loop through the message and write to CM log
           fnd_file.put_line(fnd_file.log,'====================================');
           fnd_file.put_line(fnd_file.log,'Termination Interface - LOG MESSAGES');
           fnd_file.put_line(fnd_file.log,'====================================');
           fnd_file.put_line(fnd_file.log,'Operating Unit :'||l_org_name);
           fnd_file.put_line(fnd_file.log,'Run Date       :'||SYSDATE);
           fnd_file.new_line(fnd_file.log);
           fnd_file.put_line(fnd_file.log,'-----------------------');
           fnd_file.put_line(fnd_file.log,'SUMMARY OF TRANSACTIONS');
           fnd_file.put_line(fnd_file.log,'-----------------------');
           fnd_file.new_line(fnd_file.log);
           fnd_file.put_line(fnd_file.log,'Processed Successfully        : '||pro_count);
           fnd_file.put_line(fnd_file.log,'Not Processed Due To Errors   : '||val_count);
           fnd_file.put_line(fnd_file.log,'Processed with Errors         : '||err_count);
           fnd_file.new_line(fnd_file.log);
           fnd_file.put_line(fnd_file.log,'Total Records                 : '||tot_count);
           fnd_file.new_line(fnd_file.log);
           IF (val_log_tbl.COUNT > 0) THEN
               fnd_file.put_line(fnd_file.log,'----------------------------------------');
               fnd_file.put_line(fnd_file.log,'TRANSACTIONS NOT PROCESSED DUE TO ERRORS');
               fnd_file.put_line(fnd_file.log,'----------------------------------------');
               FOR record_number in val_log_tbl.FIRST..val_log_tbl.LAST LOOP
                   fnd_file.new_line(fnd_file.log);
                   fnd_file.put_line(fnd_file.log,'Transaction Number        : '||val_log_tbl(record_number).transaction_number);
                   fnd_file.put_line(fnd_file.log,'Contract Number           : '||val_log_tbl(record_number).contract_number);
                   fnd_file.put_line(fnd_file.log,'Quote Effective From Date : '||val_log_tbl(record_number).date_effective_from);
                   -- to find the meaning of quote_type_code
                   l_quote_type := NULL;
                   FOR get_type IN get_quote_type_meaning_csr(p_quote_type => val_log_tbl(record_number).quote_type)
                   LOOP
                       l_quote_type := get_type.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.log,'Quote Type                : ');
                   IF(l_quote_type IS NOT NULL) THEN
                      fnd_file.put(fnd_file.log,l_quote_type);
                   END IF;
                   fnd_file.put_line(fnd_file.log,'( '||val_log_tbl(record_number).quote_type||' )');
                   -- to find the meaning of quote_reason_code
                   l_quote_reason := NULL;
                   FOR get_reason IN get_quote_reason_meaning_csr(p_quote_reason => val_log_tbl(record_number).quote_reason)
                   LOOP
                       l_quote_reason  := get_reason.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.log,'Quote Reason              : ');
                   IF(l_quote_reason IS NOT NULL) THEN
                      fnd_file.put(fnd_file.log,l_quote_reason);
                   END IF;
                   fnd_file.put_line(fnd_file.log,'( '||val_log_tbl(record_number).quote_reason||' )');
                   fnd_file.put_line(fnd_file.log,'Asset Number              : '||val_log_tbl(record_number).asset_number);
                   fnd_file.put_line(fnd_file.log,'Messages ');
                   count_msg := 1;
                   -- modified for BUG#3062867
                   IF(val_msg_tbl.COUNT>0) THEN
                      FOR i IN val_msg_tbl.FIRST..val_msg_tbl.LAST
                      LOOP
                          IF(val_msg_tbl(i).transaction_number = val_log_tbl(record_number).transaction_number) THEN
                            fnd_file.put_line(fnd_file.log,count_msg||': '||val_msg_tbl(i).msg_text);
                            count_msg := count_msg+1;
                          END IF;
                      END LOOP;
                   END IF;

                   fnd_file.new_line(fnd_file.log);
               END LOOP;
           END IF; -- val_log_tbl COUNT > 0
           IF (err_log_tbl.COUNT > 0) THEN
               fnd_file.put_line(fnd_file.log,'----------------------------------');
               fnd_file.put_line(fnd_file.log,'TRANSACTIONS PROCESSED WITH ERRORS');
               fnd_file.put_line(fnd_file.log,'----------------------------------');
               FOR record_number in err_log_tbl.FIRST..err_log_tbl.LAST LOOP
                   fnd_file.new_line(fnd_file.log);
                   fnd_file.put_line(fnd_file.log,'Transaction Number        : '||err_log_tbl(record_number).transaction_number);
                   fnd_file.put_line(fnd_file.log,'Contract Number           : '||err_log_tbl(record_number).contract_number);
                   fnd_file.put_line(fnd_file.log,'Quote Effective From Date : '||err_log_tbl(record_number).date_effective_from);
                   -- to find the meaning of quote_type_code
                   l_quote_type := NULL;
                   FOR get_type IN get_quote_type_meaning_csr(p_quote_type => err_log_tbl(record_number).quote_type)
                   LOOP
                       l_quote_type := get_type.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.log,'Quote Type                : ');
                   IF(l_quote_type IS NOT NULL) THEN
                      fnd_file.put(fnd_file.log,l_quote_type);
                   END IF;
                   fnd_file.put_line(fnd_file.log,'( '||err_log_tbl(record_number).quote_type||' )');
                   -- to find the meaning of quote_reason_code
                   l_quote_reason := NULL;
                   FOR get_reason IN get_quote_reason_meaning_csr(p_quote_reason => err_log_tbl(record_number).quote_reason)
                   LOOP
                       l_quote_reason  := get_reason.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.log,'Quote Reason              : ');
                   IF(l_quote_reason IS NOT NULL) THEN
                      fnd_file.put(fnd_file.log,l_quote_reason);
                   END IF;
                   fnd_file.put_line(fnd_file.log,'( '||err_log_tbl(record_number).quote_reason||' )');
                   fnd_file.put_line(fnd_file.log,'Asset Number              : '||err_log_tbl(record_number).asset_number);
                   fnd_file.put_line(fnd_file.log,'Quote Number              : '||err_log_tbl(record_number).quote_number);
                   fnd_file.put_line(fnd_file.log,'Messages ');
                   count_msg := 1;

                   -- modified for BUG#3062867
                   IF(err_msg_tbl.COUNT>0) THEN
                      FOR i IN err_msg_tbl.FIRST..err_msg_tbl.LAST
                      LOOP
                          IF(err_msg_tbl(i).transaction_number = err_log_tbl(record_number).transaction_number) THEN
                            fnd_file.put_line(fnd_file.log,count_msg||': '||err_msg_tbl(i).msg_text);
                            count_msg := count_msg+1;
                          END IF;
                      END LOOP;
                   END IF;

                   fnd_file.new_line(fnd_file.log);
               END LOOP;
           END IF; -- err_log_tbl COUNT > 0
           count_msg := 1;
           -- statement came along with flag 'Y'
           IF(msg_tbl.COUNT>0) THEN
              FOR i IN msg_tbl.FIRST..msg_tbl.LAST
              LOOP
                  fnd_file.put_line(fnd_file.log,count_msg ||': '||msg_tbl(i).msg_text);
                  count_msg := count_msg+1;
              END LOOP;
           END IF;
           fnd_file.put_line(fnd_file.log,'=======================================');
       END IF;
       -- enter the messages in to OUTPUT
       IF(log_msg_flag = 'O') THEN
           tot_count := p_quote_number;
           val_count := val_log_tbl.COUNT;
           err_count := err_log_tbl.COUNT;
           pro_count := tot_count-(val_count+err_count);
          -- cursor to retrieve operating unit name
           FOR org_rec IN org_csr (l_org_id) LOOP
               l_org_name := org_rec.name;
           END LOOP;
           -- loop through the message and write to CM log
           fnd_file.put_line(fnd_file.output,'=======================================');
           fnd_file.put_line(fnd_file.output,'Termination Interface - OUTPUT MESSAGES');
           fnd_file.put_line(fnd_file.output,'=======================================');
           fnd_file.put_line(fnd_file.output,'Operating Unit :'||l_org_name);
           fnd_file.put_line(fnd_file.output,'Run Date       :'||SYSDATE);
           fnd_file.new_line(fnd_file.output);
           fnd_file.put_line(fnd_file.output,'-----------------------');
           fnd_file.put_line(fnd_file.output,'SUMMARY OF TRANSACTIONS');
           fnd_file.put_line(fnd_file.output,'-----------------------');
           fnd_file.new_line(fnd_file.output);
           fnd_file.put_line(fnd_file.output,'Processed Successfully        : '||pro_count);
           fnd_file.put_line(fnd_file.output,'Not Processed Due To Errors   : '||val_count);
           fnd_file.put_line(fnd_file.output,'Processed with Errors         : '||err_count);
           fnd_file.new_line(fnd_file.output);
           --pro_count := pro_log_tbl.COUNT+val_log_tbl.COUNT+err_log_tbl.COUNT;
           fnd_file.put_line(fnd_file.output,'Total Records                 : '||tot_count);
           fnd_file.new_line(fnd_file.output);
           IF (val_log_tbl.COUNT > 0) THEN
               fnd_file.put_line(fnd_file.output,'----------------------------------------');
               fnd_file.put_line(fnd_file.output,'TRANSACTIONS NOT PROCESSED DUE TO ERRORS');
               fnd_file.put_line(fnd_file.output,'----------------------------------------');
               FOR record_number in val_log_tbl.FIRST..val_log_tbl.LAST LOOP
                   fnd_file.new_line(fnd_file.output);
                   fnd_file.put_line(fnd_file.output,'Transaction Number        : '||val_log_tbl(record_number).transaction_number);
                   fnd_file.put_line(fnd_file.output,'Contract Number           : '||val_log_tbl(record_number).contract_number);
                   fnd_file.put_line(fnd_file.output,'Quote Effective From Date : '||val_log_tbl(record_number).date_effective_from);

                   -- to find the meaning of quote_type_code
                   l_quote_type := NULL;
                   FOR get_type IN get_quote_type_meaning_csr(p_quote_type => val_log_tbl(record_number).quote_type)
                   LOOP
                       l_quote_type := get_type.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.output,'Quote Type                : ');
                   IF(l_quote_type IS NOT NULL) THEN
                      fnd_file.put(fnd_file.output,l_quote_type);
                   END IF;
                   fnd_file.put_line(fnd_file.output,'( '||val_log_tbl(record_number).quote_type||' )');
                   -- to find the meaning of quote_reason_code
                   l_quote_reason := NULL;
                   FOR get_reason IN get_quote_reason_meaning_csr(p_quote_reason => val_log_tbl(record_number).quote_reason)
                   LOOP
                       l_quote_reason  := get_reason.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.output,'Quote Reason              : ');
                   IF(l_quote_reason IS NOT NULL) THEN
                      fnd_file.put(fnd_file.output,l_quote_reason);
                   END IF;
                   fnd_file.put_line(fnd_file.output,'( '||val_log_tbl(record_number).quote_reason||' )');
                   fnd_file.put_line(fnd_file.output,'Asset Number              : '||val_log_tbl(record_number).asset_number);
                   fnd_file.put_line(fnd_file.output,'Messages ');
                   count_msg := 1;

                   -- modified for BUG#3062867
                   IF(val_msg_tbl.COUNT>0) THEN
                      FOR i IN val_msg_tbl.FIRST..val_msg_tbl.LAST
                      LOOP
                          IF(val_msg_tbl(i).transaction_number = val_log_tbl(record_number).transaction_number) THEN
                            fnd_file.put_line(fnd_file.output,count_msg||': '||val_msg_tbl(i).msg_text);
                            count_msg := count_msg+1;
                          END IF;
                      END LOOP;
                   END IF;

                   fnd_file.new_line(fnd_file.output);
               END LOOP;
           END IF; -- val_msg_tbl COUNT > 0
           IF (err_log_tbl.COUNT > 0) THEN
               fnd_file.put_line(fnd_file.output,'----------------------------------');
               fnd_file.put_line(fnd_file.output,'TRANSACTIONS PROCESSED WITH ERRORS');
               fnd_file.put_line(fnd_file.output,'----------------------------------');
               FOR record_number in err_log_tbl.FIRST..err_log_tbl.LAST LOOP
                   fnd_file.new_line(fnd_file.output);
                   fnd_file.put_line(fnd_file.output,'Transaction Number        : '||err_log_tbl(record_number).transaction_number);
                   fnd_file.put_line(fnd_file.output,'Contract Number           : '||err_log_tbl(record_number).contract_number);
                   fnd_file.put_line(fnd_file.output,'Quote Effective From Date : '||err_log_tbl(record_number).date_effective_from);
                   -- to find the meaning of quote_type_code
                   l_quote_type := NULL;
                   FOR get_type IN get_quote_type_meaning_csr(p_quote_type => err_log_tbl(record_number).quote_type)
                   LOOP
                       l_quote_type := get_type.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.output,'Quote Type                : ');
                   IF(l_quote_type IS NOT NULL) THEN
                      fnd_file.put(fnd_file.output,l_quote_type);
                   END IF;
                   fnd_file.put_line(fnd_file.output,'( '||err_log_tbl(record_number).quote_type||' )');
                   -- to find the meaning of quote_reason_code
                   l_quote_reason := NULL;
                   FOR get_reason IN get_quote_reason_meaning_csr(p_quote_reason => err_log_tbl(record_number).quote_reason)
                   LOOP
                       l_quote_reason  := get_reason.meaning;
                   END LOOP;
                   fnd_file.put(fnd_file.output,'Quote Reason              : ');
                   IF(l_quote_reason IS NOT NULL) THEN
                      fnd_file.put(fnd_file.output,l_quote_reason);
                   END IF;
                   fnd_file.put_line(fnd_file.output,'( '||err_log_tbl(record_number).quote_reason||' )');
                   fnd_file.put_line(fnd_file.output,'Asset Number              : '||err_log_tbl(record_number).asset_number);
                   fnd_file.put_line(fnd_file.output,'Quote Number              : '||err_log_tbl(record_number).quote_number);
                   fnd_file.put_line(fnd_file.output,'Messages ');
                   count_msg := 1;

                   -- modified for BUG#3062867
                   IF(err_msg_tbl.COUNT>0) THEN
                      FOR i IN err_msg_tbl.FIRST..err_msg_tbl.LAST
                      LOOP
                          IF(err_msg_tbl(i).transaction_number = err_log_tbl(record_number).transaction_number) THEN
                            fnd_file.put_line(fnd_file.output,count_msg||': '||err_msg_tbl(i).msg_text);
                            count_msg := count_msg+1;
                          END IF;
                      END LOOP;
                   END IF;

                   fnd_file.new_line(fnd_file.output);
               END LOOP;
           END IF; -- err_log_tbl COUNT > 0
           count_msg := 1;
           IF(msg_tbl.COUNT>0) THEN
              FOR i IN msg_tbl.FIRST..msg_tbl.LAST
              LOOP
                  fnd_file.put_line(fnd_file.output,count_msg ||': '||msg_tbl(i).msg_text);
                  count_msg := count_msg+1;
              END LOOP;
           END IF;
           fnd_file.put_line(fnd_file.output,'=======================================');
       END IF;
       EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);
    END log_messages;

  -- Start of comments
  --
  -- Procedure Name  : validate_quote_type_and_reason
  -- Description     : This procedure checks whether quote_type and quote_reason are valid
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tif_tbl, p_sys_date
  -- Version         : 1.0
  -- History         : 11-MAR-03 RABHUPAT Created
  -- End of comments

  PROCEDURE validate_quote_type_and_reason(p_api_version    IN NUMBER,
                                           p_init_msg_list  IN VARCHAR2,
                                           x_msg_count      OUT NOCOPY NUMBER,
                                           x_msg_data       OUT NOCOPY VARCHAR2,
                                           x_return_status  OUT NOCOPY VARCHAR2,
                                           p_tif_tbl        IN tif_tbl_type,
                                           x_tif_tbl        OUT NOCOPY tif_tbl_type) IS
  /* cursor retrives the distinct quote_types from INTERFACE TABLE*/
  CURSOR get_quote_type_csr IS
  SELECT DISTINCT(quote_type_code) quote_type
  FROM OKL_TERMNT_INTERFACE
  WHERE status = 'ENTERED' AND quote_type_code IS NOT NULL;

  /* validates each quote_type in INTERFACE table against FND_LOOKUPS*/
  CURSOR validate_quote_type_csr(p_quote_type IN VARCHAR2) IS
  SELECT COUNT(lookup_code) code
  FROM FND_LOOKUPS
  WHERE lookup_code = p_quote_type AND lookup_type = 'OKL_QUOTE_TYPE' AND enabled_flag = 'Y';

  /* cursor retrives the distinct quote_reason from INTERFACE TABLE*/
  CURSOR get_quote_reason_csr IS
  SELECT DISTINCT(quote_reason_code) quote_reason
  FROM OKL_TERMNT_INTERFACE
  WHERE status = 'ENTERED' AND quote_reason_code IS NOT NULL;

  /* validates each quote_reason in INTERFACE table against FND_LOOKUPS*/
  CURSOR validate_quote_reason_csr(p_quote_reason IN VARCHAR2) IS
  SELECT COUNT(lookup_code) code
  FROM FND_LOOKUPS
  WHERE lookup_code = p_quote_reason AND lookup_type = 'OKL_QUOTE_REASON' AND enabled_flag = 'Y';

  l_quote_type             VARCHAR2(20) :='';
  l_quote_reason           VARCHAR2(30) :='';
  l_code                   NUMBER       := 0;
  lp_tif_tbl               tif_tbl_type;
  l_msg_tbl                msg_tbl_type;
  BEGIN
       x_return_status := OKC_API.G_RET_STS_SUCCESS;
       lp_tif_tbl    :=  p_tif_tbl;
       IF(lp_tif_tbl.COUNT>0) THEN
       --loops through the interface table records to populate WHO_columns
          FOR record_number IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
          LOOP
              lp_tif_tbl(record_number).CREATION_DATE            := SYSDATE;
              lp_tif_tbl(record_number).CREATED_BY               := FND_GLOBAL.USER_ID;
          END LOOP;
       END IF;
       /* cursor retrives the distinct quote_types from INTERFACE TABLE*/
       FOR term_rec IN get_quote_type_csr
       LOOP
           l_quote_type  := term_rec.quote_type;
           l_code        := 0;
          /* validates each quote_type in INTERFACE table against FND_LOOKUPS*/
           FOR check_type IN validate_quote_type_csr(p_quote_type => l_quote_type)
           LOOP
               l_code  := check_type.code;
           END LOOP;
           /* if quote_type not exists in FND_LOOKUPS then  ERROR out corresponding columns */
           IF(l_code = 0)THEN
              IF(lp_tif_tbl.COUNT>0) THEN
                 /*loops through the interface table records */
                 FOR record_number IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
                 LOOP
                     IF(lp_tif_tbl(record_number).quote_type_code = l_quote_type) THEN
                        -- quote type entered is invalid
                        lp_tif_tbl(record_number).status := 'ERROR';
                        OKC_API.set_message(p_app_name      => g_app_name,
                                            p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                            p_token1        => 'COL_NAME',
                                            p_token1_value  => 'QUOTE_TYPE_CODE');
                        l_msg_tbl(0).msg_text                :=  'quote type: '||l_quote_type||' entered for transaction number: '||lp_tif_tbl(record_number).transaction_number ||' is not valid ';
                        log_messages(log_msg_flag             => 'V',
                                     p_transaction_number     => lp_tif_tbl(record_number).transaction_number,
                                     p_contract_number        => lp_tif_tbl(record_number).contract_number,
                                     p_asset_number           => lp_tif_tbl(record_number).asset_number,
                                     p_date_effective         => lp_tif_tbl(record_number).date_effective_from,
                                     p_quote_type             => lp_tif_tbl(record_number).quote_type_code,
                                     p_quote_reason           => lp_tif_tbl(record_number).quote_reason_code,
                                     msg_tbl                  => l_msg_tbl);
                     END IF;
                 END LOOP;
              END IF;
           ELSE
               IF(lp_tif_tbl.COUNT>0) THEN
                  /*loops through the interface table records */
                  FOR record_number IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
                  LOOP
                     IF(lp_tif_tbl(record_number).quote_type_code LIKE 'TER_MAN%') THEN
                        --manual quotes are not allowed
                        lp_tif_tbl(record_number).status := 'ERROR';
                        OKC_API.set_message(p_app_name      => g_app_name,
                                            p_msg_name      => 'OKL_AM_MAN_QUOTE_TYPE',
                                            p_token1        => 'TRANSACTION NUMBER',
                                            p_token1_value  => lp_tif_tbl(record_number).transaction_number);
                        l_msg_tbl(0).msg_text                := 'manual quotes not allowed for transaction number '||lp_tif_tbl(record_number).transaction_number;
                        log_messages(log_msg_flag             => 'V',
                                     p_transaction_number     => lp_tif_tbl(record_number).transaction_number,
                                     p_contract_number        => lp_tif_tbl(record_number).contract_number,
                                     p_asset_number           => lp_tif_tbl(record_number).asset_number,
                                     p_date_effective         => lp_tif_tbl(record_number).date_effective_from,
                                     p_quote_type             => lp_tif_tbl(record_number).quote_type_code,
                                     p_quote_reason           => lp_tif_tbl(record_number).quote_reason_code,
                                     msg_tbl                  => l_msg_tbl);
                     --Bug# 3925453: pagarg +++ T and A +++++++ Start ++++++++++
                     ELSIF(lp_tif_tbl(record_number).quote_type_code = 'TER_RELASE_WO_PURCHASE')
                     THEN
                         -- Release quotes are not allowed
                         lp_tif_tbl(record_number).status := 'ERROR';
                         OKC_API.set_message(p_app_name      => g_app_name,
                                             p_msg_name      => 'OKL_AM_TER_INTF_RELEASE_QTE');
                         l_msg_tbl(0).msg_text := 'Creation of Release quote is not allowed for termination interface';
                         log_messages(log_msg_flag             => 'V',
                                      p_transaction_number     => lp_tif_tbl(record_number).transaction_number,
                                      p_contract_number        => lp_tif_tbl(record_number).contract_number,
                                      p_asset_number           => lp_tif_tbl(record_number).asset_number,
                                      p_date_effective         => lp_tif_tbl(record_number).date_effective_from,
                                      p_quote_type             => lp_tif_tbl(record_number).quote_type_code,
                                      p_quote_reason           => lp_tif_tbl(record_number).quote_reason_code,
                                      msg_tbl                  => l_msg_tbl);
                     --Bug# 3925453: pagarg +++ T and A +++++++ End ++++++++++
                     END IF;
                  END LOOP;
               END IF;
           END IF;
       END LOOP;

       /* cursor retrives the distinct quote_reason from INTERFACE TABLE*/
       FOR term_rec IN get_quote_reason_csr
       LOOP
           l_quote_reason  := term_rec.quote_reason;
           l_code        := 0;
          /* validates each quote_reason in INTERFACE table against FND_LOOKUPS*/
           FOR check_reason IN validate_quote_reason_csr(p_quote_reason => l_quote_reason)
           LOOP
               l_code  := check_reason.code;
           END LOOP;
           /* if quote_reason not exists in FND_LOOKUPS then  ERROR out corresponding columns */
           IF(l_code = 0)THEN
              IF(lp_tif_tbl.COUNT>0) THEN
                 /*loops through the interface table records */
                 FOR record_number IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
                 LOOP
                     IF(lp_tif_tbl(record_number).quote_reason_code = l_quote_reason) THEN
                        -- quote reason entered is invalid
                        lp_tif_tbl(record_number).status := 'ERROR';
                        OKC_API.set_message(p_app_name      => g_app_name,
                                            p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                            p_token1        => 'COL_NAME',
                                            p_token1_value  => 'QUOTE_REASON_CODE');
                        l_msg_tbl(0).msg_text      := 'quote reason '||l_quote_reason||' entered for transaction number '||lp_tif_tbl(record_number).transaction_number ||' is not valid ';
                        log_messages(log_msg_flag             => 'V',
                                     p_transaction_number     => lp_tif_tbl(record_number).transaction_number,
                                     p_contract_number        => lp_tif_tbl(record_number).contract_number,
                                     p_asset_number           => lp_tif_tbl(record_number).asset_number,
                                     p_date_effective         => lp_tif_tbl(record_number).date_effective_from,
                                     p_quote_type             => lp_tif_tbl(record_number).quote_type_code,
                                     p_quote_reason           => lp_tif_tbl(record_number).quote_reason_code,
                                     msg_tbl                  => l_msg_tbl );
                     END IF;
                 END LOOP;
              END IF;
           END IF;
       END LOOP;
       x_tif_tbl := lp_tif_tbl;
  EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         l_msg_tbl(0).msg_text                := 'validate_quote_type_and_reason: ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
  END validate_quote_type_and_reason;

  -- Start of comments
  --
  -- Procedure Name  : validate_required
  -- Description     : This procedure checks whether required fields are entered or not
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tif_rec, p_sys_date
  -- Version         : 1.0
  -- History         : 04-FEB-03 RABHUPAT Created
  --                 : 14-APR-03 RABHUPAT added validation for auto_accept_yn
  --                 :                    removed logic for setting default for quote_reason
  --                 :                    as the column is changed to NOT NULL
  -- End of comments

    PROCEDURE validate_required(
                                p_api_version    IN NUMBER,
                                p_init_msg_list  IN VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                p_tif_rec        IN tif_rec_type,
                                p_sys_date       IN DATE,
                                x_tif_rec        OUT NOCOPY tif_rec_type) IS
   message                  VARCHAR2(200);
   l_msg_tbl                msg_tbl_type;
   BEGIN
               x_tif_rec                          := p_tif_rec;
               x_return_status := OKC_API.G_RET_STS_SUCCESS;
                --checks whether asset id or asset number entered or not
                IF((p_tif_rec.asset_id IS NULL) OR (p_tif_rec.asset_id = OKC_API.G_MISS_NUM)) THEN
                  IF((p_tif_rec.asset_number IS NULL) OR (p_tif_rec.asset_number = OKC_API.G_MISS_CHAR)) THEN
                    x_tif_rec.status := 'ERROR';
                    OKC_API.set_message(p_app_name      => g_app_name,
                                        p_msg_name      => 'OKC_AM_ASSET_REQUIRED',
                                        p_token1        => 'CONTRACT_NUMBER',
                                        p_token1_value  => p_tif_rec.contract_number);
                    message :='asset number and id not entered for contract_number '||p_tif_rec.contract_number;
                  END IF;
                END IF;
                IF(x_tif_rec.status <> 'ERROR') THEN
                   /*checks whether asset is serialized or not and if serialized checks whether quantity is one or null
                     for non serialized assets checks whether quantity entered is greater than zero or not*/
                   IF((p_tif_rec.serial_number IS NOT NULL) AND (p_tif_rec.serial_number <> OKC_API.G_MISS_CHAR)) THEN
                       IF((p_tif_rec.units_to_terminate IS NOT NULL) AND (p_tif_rec.units_to_terminate <> OKC_API.G_MISS_NUM) AND (p_tif_rec.units_to_terminate <> 1)) THEN
                           x_tif_rec.status := 'ERROR';
                           OKC_API.set_message(p_app_name      => g_app_name,
                                               p_msg_name      => 'OKL_AM_SER_ASSET_QTY',
                                               p_token1        => 'ASSET_NUMBER',
                                               p_token1_value  => p_tif_rec.asset_number,
                                               p_token2        => 'SERIAL_NUMBER',
                                               p_token2_value  => p_tif_rec.serial_number);
                           message :='serialized asset with serial number '||p_tif_rec.serial_number||' should have quantity as one ';
                      END IF;
                   ELSE
                      -- if asset quantity is less than 1
                       IF(p_tif_rec.units_to_terminate < 1) THEN
                          x_tif_rec.status := 'ERROR';
                          OKC_API.set_message(p_app_name      => g_app_name,
                                              p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                              p_token1        => 'COL_NAME',
                                              p_token1_value  => 'UNITS_TO_TERMINATE');
                          message :='asset '||p_tif_rec.asset_number||' '||p_tif_rec.asset_id||' can not have quantity less than one';
                      END IF;
                   END IF;
                END IF;

                -- defaults date_effective_from to Sysdate if null and error out if past date entered.
                IF(x_tif_rec.status <> 'ERROR') THEN
                     IF((p_tif_rec.date_effective_from IS NULL) OR (p_tif_rec.date_effective_from = OKC_API.G_MISS_DATE)) THEN
                         x_tif_rec.date_effective_from := p_sys_date;
                     --Bug 4136202 : Commented check for past date as this is now allowed (Effective dated termination impact)
                     /*ELSIF(p_tif_rec.date_effective_from < p_sys_date) THEN
                           x_tif_rec.status := 'ERROR';
                           OKC_API.set_message(p_app_name      => g_app_name,
                                               p_msg_name      => 'OKL_AM_DATE_EFF_FROM_PAST',
                                               p_token1        => 'COL_NAME',
                                               p_token1_value  => 'DATE_EFFECTIVE_FROM');
                           message :='date_effective_from '||p_tif_rec.contract_number||' should not be a past date';*/
                     END IF;
                END IF;
                /* defaults the auto_accept_yn to 'N' */
                IF(x_tif_rec.status <> 'ERROR')THEN
                   IF(x_tif_rec.auto_accept_yn IS NULL OR x_tif_rec.auto_accept_yn = OKC_API.G_MISS_CHAR)THEN
                      x_tif_rec.auto_accept_yn := 'N';
                   -- if some wrong charcter entered default it to 'N'
                   ELSIF(x_tif_rec.auto_accept_yn NOT IN ('Y','N')) THEN
                         x_tif_rec.auto_accept_yn := 'N';
                   END IF;
                END IF;
                IF(x_tif_rec.status = 'ERROR')THEN
                   l_msg_tbl(0).msg_text                := message;
                   log_messages(log_msg_flag             => 'V',
                                p_transaction_number     => x_tif_rec.transaction_number,
                                p_contract_number        => x_tif_rec.contract_number,
                                p_asset_number           => x_tif_rec.asset_number,
                                p_date_effective         => x_tif_rec.date_effective_from,
                                p_quote_type             => x_tif_rec.quote_type_code,
                                p_quote_reason           => x_tif_rec.quote_reason_code,
                                msg_tbl                  => l_msg_tbl );
                END IF;
          OKL_AM_UTIL_PVT.process_messages(
            	                           p_trx_source_table	=> 'OKL_TERMNT_INTERFACE',
        	                               p_trx_id		        => p_tif_rec.transaction_number,
        	                               x_return_status     => x_return_status);


    EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        l_msg_tbl(0).msg_text    := 'validate_required:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
        log_messages(log_msg_flag             => 'V',
                     msg_tbl                  => l_msg_tbl );
    END validate_required;

  -- Start of comments
  --
  -- Procedure Name  : validate_data
  -- Description     : This procedure checks whether data entered is appropriate
  --                 : or not, also populates the remaining columns required
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tif_rec
  -- Version         : 1.0
  -- History         : 04-FEB-03 RABHUPAT Created
  --                 : 28-MAR-03 RABHUPAT added another cursor to retrive quantity
  --                 : and changed the cursor for finding serial number and code
  -- End of comments

    PROCEDURE validate_data(
                            p_api_version    IN NUMBER,
                            p_init_msg_list  IN VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            p_tif_rec        IN tif_rec_type,
                            x_tif_rec        OUT NOCOPY tif_rec_type
                           ) IS

        l_serial_number        OKL_TERMNT_INTERFACE.serial_number%TYPE;
        l_contract_id          OKL_TERMNT_INTERFACE.contract_id%TYPE;
        l_contract_status      OKC_K_HEADERS_B.sts_code%TYPE;
        l_asset_number         OKL_TERMNT_INTERFACE.asset_number%TYPE;
        l_asset_id             OKL_TERMNT_INTERFACE.asset_id%TYPE;
        l_asset_description    OKL_TERMNT_INTERFACE.asset_description%TYPE;
        l_asset_status         OKL_K_LINES_FULL_V.sts_code%TYPE;
        l_tif_rec              tif_rec_type;
        l_quantity             NUMBER;
        l_instance_id          NUMBER;
        l_installbase_id       NUMBER;
        l_org_id               NUMBER;
	l_session_org_id       NUMBER :=         MO_GLOBAL.GET_CURRENT_ORG_ID();
        l_count_asset          NUMBER := 0;
        message                VARCHAR2(200);
        l_msg_tbl              msg_tbl_type;
    /*this cursor retrives the contract_id and status from OKC_K_HEADERS_B with contract number
      as input parameter*/
    CURSOR get_chr_dtls_csr(p_chr_no IN VARCHAR2) IS
    	   SELECT id,sts_code,authoring_org_id
           FROM okc_k_headers_b
           WHERE contract_number=p_chr_no;
    /* this cursor retrives the asset_id,asset_number,asset_status and description from okc_k_lines_v
       and okc_line_styles_v with contract_id,asset_id,asset_number as input parameters.*/
    CURSOR get_aset_dtls_csr(p_chr_id      IN NUMBER,
                             p_ast_number  IN VARCHAR2,
                             p_ast_id      IN NUMBER) IS
           SELECT oklv.id id, oklv.name num, oklv.sts_code status, oklv.item_description description
           FROM okc_k_lines_v  oklv, okc_line_styles_v ols
           WHERE oklv.chr_id= p_chr_id
           AND ((oklv.name = p_ast_number)
           OR  (oklv.id = p_ast_id))
           AND oklv.lse_id=ols.id
           AND ols.lty_code = 'FREE_FORM1';

    /* this cursor retrives the instance ids for the asset with asset_id as input parameter.*/
    CURSOR get_instance_id_csr(p_ast_id IN NUMBER) IS
           SELECT oklv.id id
           FROM okc_k_lines_v  oklv, okc_line_styles_v ols
           WHERE oklv.cle_id = p_ast_id
           AND oklv.lse_id=ols.id
           AND ols.lty_code = 'FREE_FORM2';
    /*this cursor is used to retrive the installbase id for an instance of the asset*/
    CURSOR get_installbase_id_csr(p_instance_id IN NUMBER) IS
           SELECT oklv.id id
           FROM okc_k_lines_v  oklv, okc_line_styles_v ols
           WHERE oklv.cle_id = p_instance_id
           AND oklv.lse_id=ols.id
           AND ols.lty_code = 'INST_ITEM';
    /* this cursor retrives the serial_number for the instance of the asset*/
    CURSOR get_sno_csr(p_installbase_id IN NUMBER) IS
           SELECT oiiv.serial_number sno
           FROM okc_k_items_v okiv,okx_install_items_v oiiv
           WHERE okiv.cle_id = p_installbase_id
           AND okiv.object1_id1=oiiv.instance_id;
    /* this cursor retrives the total quantity for the asset*/
    CURSOR get_qty_csr(p_asset_number IN VARCHAR2) IS
           SELECT current_units quantity
           FROM OKX_ASSETS_V
           WHERE asset_number = p_asset_number;

    BEGIN
         x_tif_rec            :=  p_tif_rec;
         x_tif_rec.status     :=  'WORKING';
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
         -- fetching the contract_id,status using the cursor
    FOR l_chr_dtl_csr IN get_chr_dtls_csr(p_chr_no => x_tif_rec.contract_number)
    LOOP
        l_contract_id          := l_chr_dtl_csr.id;
        l_contract_status      := l_chr_dtl_csr.sts_code;
        l_org_id               := l_chr_dtl_csr.authoring_org_id;
    END LOOP;
    -- contract number entered not exists
    IF(l_contract_id IS NULL OR l_contract_id = OKC_API.G_MISS_NUM) THEN
       x_tif_rec.status := 'ERROR';
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                           p_token1        => 'COL_NAME',
                           p_token1_value  => 'CONTRACT_NUMBER');
       message :='contract_number '||x_tif_rec.contract_number||' entered not exists';
    ELSIF(x_tif_rec.contract_id IS NULL OR x_tif_rec.contract_id = OKC_API.G_MISS_NUM) THEN
          x_tif_rec.contract_id := l_contract_id;
    ELSIF(x_tif_rec.contract_id <> l_contract_id) THEN
          x_tif_rec.status := 'ERROR';
          -- contract_id and contract_number entered not matches
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                              p_token1        => 'COL_NAME',
                              p_token1_value  => 'CONTRACT_NUMBER');
          message :='contract_number '||x_tif_rec.contract_number||' and contract_id '||x_tif_rec.contract_id ||' entered not matches';
    END IF;
    IF(x_tif_rec.status <> 'ERROR' AND l_contract_status NOT IN('BOOKED','EVERGREEN')) THEN
       x_tif_rec.status := 'ERROR';
       -- contract status is not in BOOKED or EVERGREEN
       -- this message is striked off in the DLD
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                           p_token1        => 'COL_NAME',
                           p_token1_value  => 'CONTRACT_NUMBER');
       message :='contract_number '||x_tif_rec.contract_number||' is not in booked state or in evergreen state';
    END IF;

    IF(x_tif_rec.status <> 'ERROR') THEN
    --fetching the asset details using the cursor
       FOR l_ast_dtl_csr IN get_aset_dtls_csr(p_chr_id     => x_tif_rec.contract_id
                                             ,p_ast_number => x_tif_rec.asset_number
                                             ,p_ast_id     => x_tif_rec.asset_id)
       LOOP
           l_asset_id                  := l_ast_dtl_csr.id;
           l_asset_number              := l_ast_dtl_csr.num;
           x_tif_rec.asset_description := l_ast_dtl_csr.description;
           l_asset_status              := l_ast_dtl_csr.status;
           l_count_asset               := l_count_asset+1;
       END LOOP;

       IF(l_count_asset >1) THEN
          x_tif_rec.status := 'ERROR';
          -- asset number and asset id not matches
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                              p_token1        => 'COL_NAME',
                              p_token1_value  => 'ASSET_NUMBER');
          message :='asset_number '||x_tif_rec.asset_number||' and asset_id '||x_tif_rec.asset_id ||' entered not matches';
       ELSIF(l_asset_id IS NULL OR l_asset_id = OKC_API.G_MISS_NUM) THEN
             x_tif_rec.status := 'ERROR';
             -- asset is not associated to contract
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                 p_token1        => 'COL_NAME',
                                 p_token1_value  => 'ASSET_NUMBER');
             message :='asset is not associated to the contract_number '||x_tif_rec.contract_number||' entered';
       ELSIF(l_asset_number IS NULL OR l_asset_number = OKC_API.G_MISS_CHAR) THEN
             x_tif_rec.status := 'ERROR';
             -- asset is not associated to contract
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                 p_token1        => 'COL_NAME',
                                 p_token1_value  => 'ASSET_NUMBER');
             message :='asset is not associated to the contract_number '||x_tif_rec.contract_number||' entered';
       ELSIF(p_tif_rec.asset_number IS NOT NULL AND p_tif_rec.asset_number <> OKC_API.G_MISS_CHAR) THEN
             IF(p_tif_rec.asset_number <> l_asset_number) THEN
                x_tif_rec.status := 'ERROR';
                -- asset id and asset number entered not matches
                OKC_API.set_message(p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                    p_token1        => 'COL_NAME',
                                    p_token1_value  => 'ASSET_NUMBER');
                message :='asset_number '||x_tif_rec.asset_number||' and asset_id '||x_tif_rec.asset_id ||' entered not matches';
             ELSIF(p_tif_rec.asset_id IS NOT NULL AND p_tif_rec.asset_id <> OKC_API.G_MISS_NUM) THEN
                   IF(p_tif_rec.asset_id <> l_asset_id) THEN
                      x_tif_rec.status := 'ERROR';
                      -- asset id and asset number entered not matches
                      OKC_API.set_message(p_app_name      => g_app_name,
                                          p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                          p_token1        => 'COL_NAME',
                                          p_token1_value  => 'ASSET_NUMBER');
                      message :='asset_number '||x_tif_rec.asset_number||' and asset_id '||x_tif_rec.asset_id ||' entered not matches';
                   END IF;
             ELSE
                 x_tif_rec.asset_id := l_asset_id;
             END IF;
       ELSIF(p_tif_rec.asset_id IS NOT NULL AND p_tif_rec.asset_id <> OKC_API.G_MISS_NUM) THEN
             IF(p_tif_rec.asset_id <> l_asset_id) THEN
                x_tif_rec.status := 'ERROR';
                -- asset id and asset number entered not matches
                OKC_API.set_message(p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                    p_token1        => 'COL_NAME',
                                    p_token1_value  => 'ASSET_NUMBER');
                message :='asset_number '||x_tif_rec.asset_number||' and asset_id '||x_tif_rec.asset_id ||' entered not matches';
             ELSIF(p_tif_rec.asset_number IS NOT NULL AND p_tif_rec.asset_number <> OKC_API.G_MISS_CHAR) THEN
                   IF(p_tif_rec.asset_number <> l_asset_number) THEN
                      x_tif_rec.status := 'ERROR';
                      -- asset id and asset number entered not matches
                      OKC_API.set_message(p_app_name      => g_app_name,
                                          p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                          p_token1        => 'COL_NAME',
                                          p_token1_value  => 'ASSET_NUMBER');
                      message :='asset_number '||x_tif_rec.asset_number||' and asset_id '||x_tif_rec.asset_id ||' entered not matches';
                   END IF;
             ELSE
                 x_tif_rec.asset_number := l_asset_number;
             END IF;
       ELSIF(l_asset_status NOT IN('BOOKED','EVERGREEN')) THEN
             x_tif_rec.status := 'ERROR';
             -- asset status is not in BOOKED or EVERGREEN
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                 p_token1        => 'COL_NAME',
                                 p_token1_value  => 'ASSET_NUMBER');
             message :='asset_number '||x_tif_rec.asset_number||' is not in booked state or in evergreen state';
       END IF;
       IF(x_tif_rec.status <> 'ERROR') THEN
          IF(x_tif_rec.serial_number IS NOT NULL AND x_tif_rec.serial_number <> OKC_API.G_MISS_CHAR) THEN
             x_tif_rec.status := 'ENTERED';
             --fetching instance_id using cursor
             FOR l_instance_id_csr IN get_instance_id_csr(p_ast_id => x_tif_rec.asset_id)
             LOOP
                 l_instance_id := l_instance_id_csr.id;
                 IF(l_instance_id IS NULL OR l_instance_id = OKC_API.G_MISS_NUM) THEN
                    x_tif_rec.status := 'ERROR';
                    -- instance line not present for the asset
                    OKC_API.set_message(p_app_name      => g_app_name,
                                        p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                        p_token1        => 'COL_NAME',
                                        p_token1_value  => 'SERIAL_NUMBER');
                   message :='instance line is not present for the asset '||x_tif_rec.asset_number;
                 ELSE
                     --fetch installbase_id using cursor
                     FOR l_installbase_id_csr IN get_installbase_id_csr(p_instance_id => l_instance_id)
                     LOOP
                         l_installbase_id := l_installbase_id_csr.id;
                     END LOOP;
                     IF(l_installbase_id IS NULL OR l_installbase_id = OKC_API.G_MISS_NUM) THEN
                        x_tif_rec.status := 'ERROR';
                        -- installbase has no entries for the instance
                        OKC_API.set_message(p_app_name      => g_app_name,
                                            p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                            p_token1        => 'COL_NAME',
                                            p_token1_value  => 'SERIAL_NUMBER');
                        message :='installbase line is not present for the asset '||x_tif_rec.asset_number;
                        EXIT;
                     ELSE
                         -- cursor to find serial number
                         FOR l_sno_csr IN get_sno_csr(p_installbase_id => l_installbase_id)
                         LOOP
                             l_serial_number := l_sno_csr.sno;
                         END LOOP;
                         IF(l_serial_number = x_tif_rec.serial_number) THEN
                            x_tif_rec.status := 'WORKING';
                            x_tif_rec.units_to_terminate := 1;
                            EXIT;
                         ELSIF(l_serial_number IS NULL OR l_serial_number = OKC_API.G_MISS_CHAR) THEN
                               x_tif_rec.status := 'ERROR';
                               -- asset is not serialized
                               OKC_API.set_message(p_app_name      => g_app_name,
                                                   p_msg_name      => 'OKC_AM_NO_SERIALIZED_ASSET',
                                                   p_token1        => 'COL_NAME',
                                                   p_token1_value  => 'ASSET_NUMBER');
                               message :='asset is not serialized '||x_tif_rec.asset_number;
                               EXIT;
                         END IF;
                     END IF;
                 END IF;
             END LOOP;
             IF(x_tif_rec.status = 'ENTERED') THEN
                x_tif_rec.status := 'ERROR';
                -- enter serial number associated for this asset
                OKC_API.set_message(p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                    p_token1        => 'COL_NAME',
                                    p_token1_value  => 'SERIAL_NUMBER');
                message :='Enter serial number associated for this asset '||x_tif_rec.asset_number;
             END IF;
          ELSE
              -- cursor to get the asset quantity
              FOR l_qty_csr IN get_qty_csr(p_asset_number => x_tif_rec.asset_number)
              LOOP
                  l_quantity := l_qty_csr.quantity;
              END LOOP;
              IF(l_quantity < x_tif_rec.units_to_terminate) THEN
                 x_tif_rec.status := 'ERROR';
                 -- quantity entered is more than asset quantity
                 OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => 'OKL_AM_INVALID_ASSET_QTY',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => x_tif_rec.asset_number);
                 message :='no.of units entered to terminate is more than the quantity associated with asset '||x_tif_rec.asset_number;
              END IF;
          END IF;
       END IF; -- instance line
    END IF; -- asset if
    IF(x_tif_rec.status <> 'ERROR') THEN
    -- validate the session ORG_ID with the contract authoring_org_id, if org_id null then assign authoring_org_id
       IF((p_tif_rec.org_id IS NULL) OR (p_tif_rec.org_id = OKC_API.G_MISS_NUM)) THEN
           x_tif_rec.org_id := l_org_id;
       END IF;
       IF(x_tif_rec.org_id <> l_session_org_id) THEN
           x_tif_rec.status := 'ENTERED';
           -- org_id not matches with session org_id so not processing it, but status remains in ENTERED
           OKC_API.set_message(p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                               p_token1        => 'COL_NAME',
                               p_token1_value  => 'ORG_ID');
           message :='org id is not for this session, not errored out';
       END IF;
    END IF;

    --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
    --------------------------
    -- Validation of quote type and auto_accepted_yn flag
    --------------------------
    -- If quote type is rollover quote and auto_accepted_yn is 'Y' then throw
    -- error as rollover quote can be accepted from rolled over contract only
    IF(x_tif_rec.status <> 'ERROR')
    THEN
      -- Check if quote type is rollover quote and auto_accept_yn is 'Y' then
      -- set the status of record to ERROR and store the error message
      IF p_tif_rec.quote_type_code LIKE 'TER_ROLL%'
      AND p_tif_rec.auto_accept_yn = 'Y'
      THEN
        x_tif_rec.status := 'ERROR';
        OKC_API.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKL_NO_ACPT_ROLL_QTE');
        message := 'Rollover quotes can only be accepted from booking process of a rolled over contract';
      END IF;
    END IF;
    --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

    IF(x_tif_rec.status = 'ERROR')THEN
       l_msg_tbl(0).msg_text    := message;
       log_messages(log_msg_flag             => 'V',
                    p_transaction_number     => x_tif_rec.transaction_number,
                    p_contract_number        => x_tif_rec.contract_number,
                    p_asset_number           => x_tif_rec.asset_number,
                    p_date_effective         => x_tif_rec.date_effective_from,
                    p_quote_type             => x_tif_rec.quote_type_code,
                    p_quote_reason           => x_tif_rec.quote_reason_code,
                    msg_tbl                  => l_msg_tbl );
    END IF;
    OKL_AM_UTIL_PVT.process_messages(p_trx_source_table    => 'OKL_TERMNT_INTERFACE',
                                     p_trx_id              => p_tif_rec.transaction_number,
                                     x_return_status       => x_return_status);
    EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        l_msg_tbl(0).msg_text    := 'validate_data: ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
        log_messages(log_msg_flag             => 'V',
                     msg_tbl                  => l_msg_tbl );
    END validate_data;

  -- Start of comments
  --
  -- Procedure Name  : validate_record
  -- Description     : This procedure calls validate_required and
  --                 : validate_data procedures
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tif_rec
  -- Version         : 1.0
  -- History         : 04-FEB-03 RABHUPAT Created
  --                 : 28-MAR-03 RABHUPAT removed parameters for counting successful
  --                 : transactions for validate_required and validate_data
  -- End of comments

    PROCEDURE validate_record(
                              p_api_version    IN NUMBER,
                              p_init_msg_list  IN VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              p_tif_rec        IN tif_rec_type,
                              p_sys_date       IN DATE,
                              x_tif_rec        OUT NOCOPY tif_rec_type
                              ) IS
    l_tif_rec                tif_rec_type;
    l_msg_tbl                msg_tbl_type;
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- this procedure checks whether required fields are entered or not
        validate_required(p_api_version    => p_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_sys_date       => p_sys_date,
                          p_tif_rec        => p_tif_rec,
                          x_tif_rec        => x_tif_rec);

        IF(x_tif_rec.status <> 'ERROR') THEN
         BEGIN
           l_tif_rec := x_tif_rec;
           /*this procedure validates the data against the database and also
             populates the remaining columns */
           validate_data(p_api_version    => p_api_version,
                         p_init_msg_list  => OKC_API.G_FALSE,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         x_return_status  => x_return_status,
                         p_tif_rec        => l_tif_rec,
                         x_tif_rec        => x_tif_rec);
         END;
        END IF;
    EXCEPTION
          WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => g_unexpected_error,
                              p_token1        => g_sqlcode_token,
                              p_token1_value  => sqlcode,
                              p_token2        => g_sqlerrm_token,
                              p_token2_value  => sqlerrm);
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          l_msg_tbl(0).msg_text                := 'validate_record: ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
          log_messages(log_msg_flag             => 'V',
                       msg_tbl                  => l_msg_tbl );
    END validate_record;

      -- Start of comments
      --
      -- Procedure Name  : validate_transaction
      -- Description     : this procedure accepts table of records and passes
      --                 : each record to the validate_record
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_tbl
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      --                 : 28-MAR-03 RABHUPAT removed parameters for counting successful
      --                 : transactions for validate_required and validate_data

      -- End of comments

    PROCEDURE validate_transaction(
                                   p_api_version    IN NUMBER,
                                   p_init_msg_list  IN VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   p_tif_tbl        IN tif_tbl_type,
                                   p_sys_date       IN DATE,
                                   x_tif_tbl        OUT NOCOPY tif_tbl_type
                                  ) IS
    record_number           NUMBER;
    l_msg_tbl               msg_tbl_type;
    BEGIN
        record_number:=0;
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (p_tif_tbl.COUNT > 0) THEN
          record_number := p_tif_tbl.FIRST;
          LOOP
            IF(p_tif_tbl(record_number).status <> 'ERROR') THEN
            -- this procedure validates the record
            validate_record(p_api_version    => p_api_version,
                            p_init_msg_list  => OKC_API.G_FALSE,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            x_return_status  => x_return_status,
                            p_sys_date       => p_sys_date,
                            p_tif_rec        => p_tif_tbl(record_number),
                            x_tif_rec        => x_tif_tbl(record_number));
            ELSE
                x_tif_tbl(record_number) := p_tif_tbl(record_number);
            END IF;
            EXIT WHEN (record_number = p_tif_tbl.LAST);
            record_number := p_tif_tbl.NEXT(record_number);
          END LOOP;
         END IF;
    EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         l_msg_tbl(0).msg_text    := 'validate_transaction:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
    END validate_transaction;

      -- Start of comments
      --
      -- Procedure Name  : update_row
      -- Description     : This procedure updates the INTERFACE table with
      --                 : modified column values
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_rec
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      --                 : 28-MAR-03 RABHUPAT added WHO column updation logic
      -- End of comments


    PROCEDURE update_row(p_api_version    IN NUMBER,
                         p_init_msg_list  IN VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         p_tif_rec        IN tif_rec_type) IS
    l_api_version            CONSTANT NUMBER       := p_api_version;
    l_api_name               CONSTANT VARCHAR2(30) := 'terminate_interface';
    l_return_status          VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
    l_msg_tbl                msg_tbl_type;
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        --Check API version, initialize message list and create savepoint.
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    UPDATE  OKL_TERMNT_INTERFACE
    SET
       OKL_TERMNT_INTERFACE.TRANSACTION_NUMBER             = p_tif_rec.transaction_number
      ,OKL_TERMNT_INTERFACE.BATCH_NUMBER                   = p_tif_rec.batch_number
      ,OKL_TERMNT_INTERFACE.CONTRACT_ID                    = p_tif_rec.contract_id
      ,OKL_TERMNT_INTERFACE.CONTRACT_NUMBER                = p_tif_rec.contract_number
      ,OKL_TERMNT_INTERFACE.ASSET_ID                       = p_tif_rec.asset_id
      ,OKL_TERMNT_INTERFACE.ASSET_NUMBER                   = p_tif_rec.asset_number
      ,OKL_TERMNT_INTERFACE.ASSET_DESCRIPTION              = p_tif_rec.asset_description
      ,OKL_TERMNT_INTERFACE.SERIAL_NUMBER                  = p_tif_rec.serial_number
      ,OKL_TERMNT_INTERFACE.ORIG_SYSTEM                    = p_tif_rec.orig_system
      ,OKL_TERMNT_INTERFACE.ORIG_SYSTEM_REFERENCE          = p_tif_rec.orig_system_reference
      ,OKL_TERMNT_INTERFACE.UNITS_TO_TERMINATE             = p_tif_rec.units_to_terminate
      ,OKL_TERMNT_INTERFACE.COMMENTS                       = p_tif_rec.comments
      ,OKL_TERMNT_INTERFACE.DATE_PROCESSED                 = p_tif_rec.date_processed
      ,OKL_TERMNT_INTERFACE.DATE_EFFECTIVE_FROM            = p_tif_rec.date_effective_from
      ,OKL_TERMNT_INTERFACE.TERMINATION_NOTIFICATION_EMAIL = p_tif_rec.termination_notification_email
      ,OKL_TERMNT_INTERFACE.TERMINATION_NOTIFICATION_YN    = p_tif_rec.termination_notification_yn
      ,OKL_TERMNT_INTERFACE.AUTO_ACCEPT_YN                 = p_tif_rec.auto_accept_yn
      ,OKL_TERMNT_INTERFACE.QUOTE_TYPE_CODE                = p_tif_rec.quote_type_code
      ,OKL_TERMNT_INTERFACE.QUOTE_REASON_CODE              = p_tif_rec.quote_reason_code
      ,OKL_TERMNT_INTERFACE.QTE_ID                         = p_tif_rec.qte_id
      ,OKL_TERMNT_INTERFACE.STATUS                         = p_tif_rec.status
      ,OKL_TERMNT_INTERFACE.ORG_ID                         = p_tif_rec.org_id
      ,OKL_TERMNT_INTERFACE.REQUEST_ID                     = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1, NULL,FND_GLOBAL.CONC_REQUEST_ID),p_tif_rec.request_id)
      ,OKL_TERMNT_INTERFACE.PROGRAM_APPLICATION_ID         = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),p_tif_rec.program_application_id)
      ,OKL_TERMNT_INTERFACE.PROGRAM_ID                     = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),p_tif_rec.program_id)
      ,OKL_TERMNT_INTERFACE.PROGRAM_UPDATE_DATE            = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,p_tif_rec.program_update_date,SYSDATE)
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE_CATEGORY             = p_tif_rec.attribute_category
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE1                     = p_tif_rec.attribute1
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE2                     = p_tif_rec.attribute2
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE3                     = p_tif_rec.attribute3
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE4                     = p_tif_rec.attribute4
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE5                     = p_tif_rec.attribute5
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE6                     = p_tif_rec.attribute6
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE7                     = p_tif_rec.attribute7
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE8                     = p_tif_rec.attribute8
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE9                     = p_tif_rec.attribute9
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE10                    = p_tif_rec.attribute10
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE11                    = p_tif_rec.attribute11
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE12                    = p_tif_rec.attribute12
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE13                    = p_tif_rec.attribute13
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE14                    = p_tif_rec.attribute14
      ,OKL_TERMNT_INTERFACE.ATTRIBUTE15                    = p_tif_rec.attribute15
      ,OKL_TERMNT_INTERFACE.CREATED_BY                     = p_tif_rec.created_by
      ,OKL_TERMNT_INTERFACE.CREATION_DATE                  = p_tif_rec.creation_date
      ,OKL_TERMNT_INTERFACE.LAST_UPDATED_BY                = FND_GLOBAL.USER_ID
      ,OKL_TERMNT_INTERFACE.LAST_UPDATE_DATE               = SYSDATE
      ,OKL_TERMNT_INTERFACE.LAST_UPDATE_LOGIN              = FND_GLOBAL.LOGIN_ID
      ,OKL_TERMNT_INTERFACE.GROUP_NUMBER                   = p_tif_rec.group_number
    WHERE
         OKL_TERMNT_INTERFACE.ROWID =p_tif_rec.row_id;
        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

        OKL_AM_UTIL_PVT.process_messages(p_trx_source_table    => 'OKL_TERMNT_INTERFACE',
                                         p_trx_id              => p_tif_rec.transaction_number,
                                         x_return_status       => l_return_status);
        x_return_status := l_return_status;
    EXCEPTION
         WHEN OKC_API.G_EXCEPTION_ERROR THEN
          x_return_status := OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                       G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_ERROR',
                                                       x_msg_count,
                                                       x_msg_data,
                                                      '_PVT');
         --unexpected error
         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                      G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                      x_msg_count,
                                                      x_msg_data,
                                                      '_PVT');
         WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => g_unexpected_error,
                              p_token1        => g_sqlcode_token,
                              p_token1_value  => sqlcode,
                              p_token2        => g_sqlerrm_token,
                              p_token2_value  => sqlerrm);
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
          l_msg_tbl(0).msg_text                := 'update_row:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
          log_messages(log_msg_flag             => 'V',
                       msg_tbl                  => l_msg_tbl );
    END update_row;

      -- Start of comments
      --
      -- Procedure Name  : change_status
      -- Description     : This procedure calls the update_row, also divides the
      --                 : Entries into batches
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_tbl
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      -- End of comments

    PROCEDURE change_status(
                            p_api_version    IN NUMBER,
                            p_init_msg_list  IN VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            p_tif_tbl        IN tif_tbl_type,
                            x_tif_tbl        OUT NOCOPY tif_tbl_type
                            ) IS
    record_number            NUMBER;
    l_msg_tbl                msg_tbl_type;
    /* this cursor rearranges the data by using the columns contract_number,
       quote_type_code, quote_reason_code and asset_id */
    CURSOR get_termnt_intface_dtls_csr(p_status IN VARCHAR2) IS
    SELECT
       ROWID
      ,TRANSACTION_NUMBER
      ,BATCH_NUMBER
      ,CONTRACT_ID
      ,CONTRACT_NUMBER
      ,ASSET_ID
      ,ASSET_NUMBER
      ,ASSET_DESCRIPTION
      ,SERIAL_NUMBER
      ,ORIG_SYSTEM
      ,ORIG_SYSTEM_REFERENCE
      ,UNITS_TO_TERMINATE
      ,COMMENTS
      ,DATE_PROCESSED
      ,DATE_EFFECTIVE_FROM
      ,TERMINATION_NOTIFICATION_EMAIL
      ,TERMINATION_NOTIFICATION_YN
      ,AUTO_ACCEPT_YN
      ,QUOTE_TYPE_CODE
      ,QUOTE_REASON_CODE
      ,QTE_ID
      ,STATUS
      ,ORG_ID
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,GROUP_NUMBER
    FROM OKL_TERMNT_INTERFACE
    WHERE status = p_status
    ORDER BY CONTRACT_NUMBER,QUOTE_TYPE_CODE,DATE_EFFECTIVE_FROM,QUOTE_REASON_CODE,ASSET_ID;
    BEGIN
        record_number:=0;
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF (p_tif_tbl.COUNT > 0) THEN
          record_number := p_tif_tbl.FIRST;
          -- loops through the table of records to update the values
          LOOP
              update_row(p_api_version   => p_api_version
                        ,p_init_msg_list => OKC_API.G_FALSE
                        ,x_msg_data      => x_msg_data
                        ,x_msg_count     => x_msg_count
                        ,x_return_status => x_return_status
                        ,p_tif_rec       => p_tif_tbl(record_number));
            EXIT WHEN (record_number = p_tif_tbl.LAST);
            record_number := p_tif_tbl.NEXT(record_number);
          END LOOP;
        END IF;
        record_number:=0;
        x_tif_tbl.DELETE;
        -- populates the plsql table with rows having status as 'WORKING'
        FOR termnt_rec IN get_termnt_intface_dtls_csr(p_status=>'WORKING')
        LOOP
        x_tif_tbl(record_number).row_id                         :=  termnt_rec.rowid;
        x_tif_tbl(record_number).transaction_number             :=  termnt_rec.transaction_number;
        x_tif_tbl(record_number).batch_number                   :=  termnt_rec.batch_number;
        x_tif_tbl(record_number).contract_id                    :=  termnt_rec.contract_id;
        x_tif_tbl(record_number).contract_number                :=  termnt_rec.contract_number;
        x_tif_tbl(record_number).asset_id                       :=  termnt_rec.asset_id;
        x_tif_tbl(record_number).asset_number                   :=  termnt_rec.asset_number;
        x_tif_tbl(record_number).asset_description              :=  termnt_rec.asset_description;
        x_tif_tbl(record_number).serial_number                  :=  termnt_rec.serial_number;
        x_tif_tbl(record_number).orig_system                    :=  termnt_rec.orig_system;
        x_tif_tbl(record_number).orig_system_reference          :=  termnt_rec.orig_system_reference;
        x_tif_tbl(record_number).units_to_terminate             :=  termnt_rec.units_to_terminate;
        x_tif_tbl(record_number).comments                       :=  termnt_rec.comments;
        x_tif_tbl(record_number).date_processed                 :=  termnt_rec.date_processed;
        x_tif_tbl(record_number).date_effective_from            :=  termnt_rec.date_effective_from;
        x_tif_tbl(record_number).termination_notification_email :=  termnt_rec.termination_notification_email;
        x_tif_tbl(record_number).termination_notification_yn    :=  termnt_rec.termination_notification_yn;
        x_tif_tbl(record_number).auto_accept_yn                 :=  termnt_rec.auto_accept_yn;
        x_tif_tbl(record_number).quote_type_code                :=  termnt_rec.quote_type_code;
        x_tif_tbl(record_number).quote_reason_code              :=  termnt_rec.quote_reason_code;
        x_tif_tbl(record_number).qte_id                         :=  termnt_rec.qte_id;
        x_tif_tbl(record_number).status                         :=  termnt_rec.status;
        x_tif_tbl(record_number).org_id                         :=  termnt_rec.org_id;
        x_tif_tbl(record_number).request_id                     :=  termnt_rec.request_id;
        x_tif_tbl(record_number).program_application_id         :=  termnt_rec.program_application_id;
        x_tif_tbl(record_number).program_id                     :=  termnt_rec.program_id;
        x_tif_tbl(record_number).program_update_date            :=  termnt_rec.program_update_date;
        x_tif_tbl(record_number).attribute_category             :=  termnt_rec.attribute_category;
        x_tif_tbl(record_number).attribute1                     :=  termnt_rec.attribute1;
        x_tif_tbl(record_number).attribute2                     :=  termnt_rec.attribute2;
        x_tif_tbl(record_number).attribute3                     :=  termnt_rec.attribute3;
        x_tif_tbl(record_number).attribute4                     :=  termnt_rec.attribute4;
        x_tif_tbl(record_number).attribute5                     :=  termnt_rec.attribute5;
        x_tif_tbl(record_number).attribute6                     :=  termnt_rec.attribute6;
        x_tif_tbl(record_number).attribute7                     :=  termnt_rec.attribute7;
        x_tif_tbl(record_number).attribute8                     :=  termnt_rec.attribute8;
        x_tif_tbl(record_number).attribute9                     :=  termnt_rec.attribute9;
        x_tif_tbl(record_number).attribute10                    :=  termnt_rec.attribute10;
        x_tif_tbl(record_number).attribute11                    :=  termnt_rec.attribute11;
        x_tif_tbl(record_number).attribute12                    :=  termnt_rec.attribute12;
        x_tif_tbl(record_number).attribute13                    :=  termnt_rec.attribute13;
        x_tif_tbl(record_number).attribute14                    :=  termnt_rec.attribute14;
        x_tif_tbl(record_number).attribute15                    :=  termnt_rec.attribute15;
        x_tif_tbl(record_number).created_by                     :=  termnt_rec.created_by;
        x_tif_tbl(record_number).creation_date                  :=  termnt_rec.creation_date;
        x_tif_tbl(record_number).last_updated_by                :=  termnt_rec.last_updated_by;
        x_tif_tbl(record_number).last_update_date               :=  termnt_rec.last_update_date;
        x_tif_tbl(record_number).last_update_login              :=  termnt_rec.last_update_login;
        x_tif_tbl(record_number).group_number                   :=  termnt_rec.group_number;
        record_number                                           :=  record_number+1;
        END LOOP;

    EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         l_msg_tbl(0).msg_text                := 'change_status:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END change_status;


      -- Start of comments
      --
      -- Procedure Name  : remove_duplicates
      -- Description     : This procedure error out the duplicate records entered
      --                 : for the quote and calls change_status to update in database
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_tbl
      -- Version         : 1.0
      -- History         : 14-MAR-03 RABHUPAT Created
      -- End of comments

    PROCEDURE remove_duplicates(p_api_version    IN NUMBER,
                                p_init_msg_list  IN VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                p_tif_tbl        IN tif_tbl_type,
                                x_tif_tbl        OUT NOCOPY tif_tbl_type) IS
         l_tif_rec              tif_rec_type;
         l_serial_number        l_tif_rec.serial_number%TYPE;
         l_contract_id          l_tif_rec.contract_id%TYPE;
         l_asset_id             l_tif_rec.asset_id%TYPE;
         l_quote_type           l_tif_rec.quote_type_code%TYPE;
         l_date_effective_from  l_tif_rec.date_effective_from%TYPE;
         lp_tif_tbl             tif_tbl_type;
         lx_tif_tbl             tif_tbl_type;
         l_reason_type          l_tif_rec.quote_reason_code%TYPE;
         l_asset_qty            NUMBER;
         l_quote_qty            NUMBER;
         message                VARCHAR2(200);
         l_msg_tbl              msg_tbl_type;
    /* this cursor retrives the total quantity for the asset*/
    CURSOR get_qty_csr(p_asset_number IN VARCHAR2) IS
           SELECT current_units quantity
           FROM OKX_ASSETS_V
           WHERE asset_number = p_asset_number;
    BEGIN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
         IF(p_tif_tbl.COUNT>0)THEN
            -- updates the values in the tbl to database and retrives the data with status='WORKING'
            change_status(p_api_version    => p_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_tif_tbl        => p_tif_tbl,
                          x_tif_tbl        => lp_tif_tbl);
         END IF;
         l_contract_id     := OKC_API.G_MISS_NUM;
         IF(lp_tif_tbl.COUNT>0 AND x_return_status = FND_API.G_RET_STS_SUCCESS)THEN
            -- loops through the interface records
            FOR term_rec IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
            LOOP
                IF((lp_tif_tbl(term_rec).contract_id         = l_contract_id)         AND
                   (lp_tif_tbl(term_rec).asset_id            = l_asset_id)            AND
                   (lp_tif_tbl(term_rec).date_effective_from = l_date_effective_from) AND
                   (lp_tif_tbl(term_rec).quote_type_code     = l_quote_type)          AND
                   (lp_tif_tbl(term_rec).quote_reason_code   = l_reason_type)        )THEN
                    IF(lp_tif_tbl(term_rec).serial_number IS NULL OR lp_tif_tbl(term_rec).serial_number = OKC_API.G_MISS_CHAR) THEN
                       IF(l_asset_qty<l_quote_qty+lp_tif_tbl(term_rec).units_to_terminate) THEN
                          lp_tif_tbl(term_rec).status := 'ERROR';
                          -- while grouping if quantity exceeds asset quantity those entries will be ERROR out
                          OKC_API.set_message(p_app_name      => g_app_name,
                                              p_msg_name      => 'OKL_AM_INVALID_ASSET_QTY',
                                              p_token1        => 'COL_NAME',
                                              p_token1_value  => 'ASSET_NUMBER');
                          message :='quote quantity exceeds asset quantity for asset '||lp_tif_tbl(term_rec).asset_number||' for transaction_number '||lp_tif_tbl(term_rec).transaction_number;
                       ELSE
                           l_quote_qty := l_quote_qty +lp_tif_tbl(term_rec).units_to_terminate;
                       END IF;
                    ELSIF(l_serial_number IS NOT NULL) THEN
                          IF(l_serial_number = lp_tif_tbl(term_rec).serial_number)THEN
                             lp_tif_tbl(term_rec).status := 'ERROR';
                             -- if same serial_number is repeated in a group tthen ERROR out
                             OKC_API.set_message(p_app_name      => g_app_name,
                                                 p_msg_name      => 'OKL_AM_DUP_LINE',
                                                 p_token1        => 'SERIAL_NUMBER',
                                                 p_token1_value  => lp_tif_tbl(term_rec).serial_number);
                             message :='duplicate record for serialized asset '||lp_tif_tbl(term_rec).asset_number||' for transaction_number '||lp_tif_tbl(term_rec).transaction_number;
                          ELSIF(l_asset_qty<l_quote_qty+lp_tif_tbl(term_rec).units_to_terminate) THEN
                                lp_tif_tbl(term_rec).status := 'ERROR';
                                -- while grouping if quantity exceeds asset quantity those entries will be ERROR out
                                OKC_API.set_message(p_app_name      => g_app_name,
                                                    p_msg_name      => 'OKL_AM_INVALID_ASSET_QTY',
                                                    p_token1        => 'COL_NAME',
                                                    p_token1_value  => 'ASSET_NUMBER');
                                message :='quote quantity exceeds asset quantity for asset '||lp_tif_tbl(term_rec).asset_number||' for transaction_number '||lp_tif_tbl(term_rec).transaction_number;
                          ELSE
                                l_quote_qty := l_quote_qty +lp_tif_tbl(term_rec).units_to_terminate;
                          END IF;
                    END IF;
                ELSE
                    l_contract_id                         := lp_tif_tbl(term_rec).contract_id;
                    l_asset_id                            := lp_tif_tbl(term_rec).asset_id;
                    l_date_effective_from                 := lp_tif_tbl(term_rec).date_effective_from;
                    l_quote_type                          := lp_tif_tbl(term_rec).quote_type_code;
                    l_reason_type                         := lp_tif_tbl(term_rec).quote_reason_code;
                    l_serial_number                       := lp_tif_tbl(term_rec).serial_number;
                    l_quote_qty                           := lp_tif_tbl(term_rec).units_to_terminate;
                    -- cursor to get the asset quantity
                    FOR l_qty_csr IN get_qty_csr(p_asset_number => lp_tif_tbl(term_rec).asset_number)
                    LOOP
                        l_asset_qty := l_qty_csr.quantity;
                    END LOOP;
                END IF;
                IF(lp_tif_tbl(term_rec).status = 'ERROR') THEN
                   l_msg_tbl(0).msg_text                 := message;
                   log_messages(log_msg_flag             => 'V',
                                p_transaction_number     => lp_tif_tbl(term_rec).transaction_number,
                                p_contract_number        => lp_tif_tbl(term_rec).contract_number,
                                p_asset_number           => lp_tif_tbl(term_rec).asset_number,
                                p_date_effective         => lp_tif_tbl(term_rec).date_effective_from,
                                p_quote_type             => lp_tif_tbl(term_rec).quote_type_code,
                                p_quote_reason           => lp_tif_tbl(term_rec).quote_reason_code,
                                msg_tbl                  => l_msg_tbl );
                END IF;
            END LOOP;
            -- updates the values in database and gets records with status='WORKING'
            change_status(p_api_version    => p_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_tif_tbl        => lp_tif_tbl,
                          x_tif_tbl        => lx_tif_tbl);
            x_tif_tbl        := lx_tif_tbl;
         END IF;
    EXCEPTION
             WHEN OTHERS THEN
             -- store SQL error message on message stack for caller
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
             x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             l_msg_tbl(0).msg_text                 := 'remove_duplicates:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
             log_messages(log_msg_flag             => 'V',
                          msg_tbl                  => l_msg_tbl );
    END remove_duplicates;

      -- Start of comments
      --
      -- Procedure Name  : create_quote
      -- Description     : This procedure calls the create_termination_quote API
      --                 : and quote_line_details API
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_tbl,p_quot_rec,p_assn_tbl,p_qpyv_tbl
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      --                 : 14-MAR-03 RABHUPAT added p_qpyv_tbl parameter
      --                 : 14-APR-03 RABHUPAT added code to accept the quotes
      --                 : rmunjulu Bug 4239780 Should not set PreProceeds flag when accepting a quote
      -- End of comments

    PROCEDURE create_quote(p_api_version    IN NUMBER,
                           p_init_msg_list  IN VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           p_tif_tbl        IN tif_tbl_type,
                           x_tif_tbl        OUT NOCOPY tif_tbl_type,
                           p_quot_rec       IN quot_rec_type,
                           p_assn_tbl       IN assn_tbl_type,
                           p_qpyv_tbl       IN qpyv_tbl_type,
                           p_batch_offset   IN NUMBER,
                           p_record_number  IN NUMBER) IS
    l_return_status        VARCHAR2(1);
    l_tif_rec              tif_rec_type;
    l_serial_number        l_tif_rec.serial_number%TYPE;
    l_quantity             l_tif_rec.units_to_terminate%TYPE;
    l_installbase_id       NUMBER;
    l_instance_id          NUMBER;
    batch_offset           NUMBER;
    record_number          NUMBER;
    l_sys_date             DATE;
    lp_quot_rec            quot_rec_type;
    lx_quot_rec            quot_rec_type;
    lp_assn_tbl            assn_tbl_type;
    lx_assn_tbl            assn_tbl_type;
    lx_tqlv_tbl            tqlv_tbl_type;
    lp_qpyv_tbl            qpyv_tbl_type;
    lp_qld_tbl             qld_tbl_type;
    qdt_counter            NUMBER;
    l_error_msg_rec        ERROR_MESSAGE_TYPE;
    l_msg_tbl              msg_tbl_type;
    l_qte_msg_count        NUMBER := 0;
    l_det_msg_count        NUMBER := 0;
    --added parameters for accepting quote logic
    l_accept_flag          VARCHAR2(1) := 'Y';
    lp_term_rec            quot_rec_type;
    lx_term_rec            quot_rec_type;
    lx_err_msg             VARCHAR2(2000);

    /* this cursor retrives the instance ids for the asset with asset_id as input parameter.*/
    CURSOR get_instance_id_csr(p_ast_id IN NUMBER) IS
           SELECT oklv.id id
           FROM okc_k_lines_v  oklv, okc_line_styles_v ols
           WHERE oklv.cle_id = p_ast_id
           AND oklv.lse_id=ols.id
           AND ols.lty_code = 'FREE_FORM2';
    /*this cursor is used to retrive the installbase id for an instance of the asset*/
    CURSOR get_installbase_id_csr(p_instance_id IN NUMBER) IS
           SELECT oklv.id id
           FROM okc_k_lines_v  oklv, okc_line_styles_v ols
           WHERE oklv.cle_id = p_instance_id
           AND oklv.lse_id=ols.id
           AND ols.lty_code = 'INST_ITEM';
    /* this cursor retrives the serial_number and quantity for the instance of the asset*/
    CURSOR get_sno_qty_csr(p_installbase_id IN NUMBER) IS
           SELECT oiiv.serial_number sno,oiiv.quantity qty
           FROM okc_k_items_v okiv,okx_install_items_v oiiv
           WHERE okiv.cle_id = p_installbase_id
           AND okiv.object1_id1=oiiv.instance_id;

    l_term_from_intf  VARCHAR2(1) := 'Y'; --sechawla 7383445 - added

    BEGIN
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
          x_tif_tbl      := p_tif_tbl;
          lp_quot_rec    := p_quot_rec;
          lp_assn_tbl    := p_assn_tbl;
          lp_qpyv_tbl    := p_qpyv_tbl;
          batch_offset   := p_batch_offset;
          qdt_counter    := 0;
          /* sysdate for date processed */
          SELECT trunc(SYSDATE) INTO l_sys_date FROM DUAL;

          --sechawla 7383445 : begin
          -- if any record which is part of this quote has auto_accept_yn='N'
          -- dont accept the quote
          FOR batch_offset IN p_batch_offset..p_record_number
          LOOP
             IF(x_tif_tbl(batch_offset).auto_accept_yn = 'N') THEN
               l_term_from_intf := 'N';
               EXIT;
             END IF;
          END LOOP;
          --sechawla 7383445 : end


          --Added new parameter p_term_from_intf by sechawla for bug 7383445
          /* calls the create_termination_quote API and retrives the quote_id */
          OKL_AM_CREATE_QUOTE_PUB.create_terminate_quote(p_api_version   => p_api_version
    	                                                ,p_init_msg_list => OKC_API.G_FALSE
    	                                                ,x_msg_data      => x_msg_data
    	                                                ,x_msg_count     => x_msg_count
    	                                                ,x_return_status => l_return_status
     	                                                ,p_quot_rec      => lp_quot_rec
    	                                                ,p_assn_tbl      => lp_assn_tbl
                                                        ,p_qpyv_tbl      => lp_qpyv_tbl
    	                                                ,x_quot_rec      => lx_quot_rec
    	                                                ,x_assn_tbl      => lx_assn_tbl
    	                                                ,x_tqlv_tbl      => lx_tqlv_tbl
    	                                                ,p_term_from_intf => l_term_from_intf); --sechawla 7383445 - added
          /* unwinding the messages from stack and keeping them in log*/
          --PAGARG 23-Feb-05 instead of calling accounting util call local procedure
          GET_ERROR_MESSAGE(l_error_msg_rec);
          IF (l_error_msg_rec.COUNT > 0) THEN
             l_qte_msg_count := 0;
             FOR m IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
             LOOP
                 IF(length(l_error_msg_rec(m))>0) THEN
                    l_msg_tbl(l_qte_msg_count).msg_text      := l_error_msg_rec(m);
                    l_qte_msg_count                          := l_qte_msg_count+1;
                 END IF;
             END LOOP;
          END IF;
          IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            LOOP
               --updates the interface records with quote_id,date_processed and status='PROCESSED'
               x_tif_tbl(batch_offset).qte_id            := lx_quot_rec.id;
               x_tif_tbl(batch_offset).status            := 'PROCESSED';
               x_tif_tbl(batch_offset).date_processed    := l_sys_date;
                   IF(x_tif_tbl(batch_offset).serial_number IS NOT NULL) THEN
                       -- cursor to get instance id
                       FOR l_instance_id_csr IN get_instance_id_csr(p_ast_id => p_tif_tbl(batch_offset).asset_id)
                       LOOP
                           l_instance_id := l_instance_id_csr.id;
                           -- cursor to find installbase id
                           FOR l_installbase_id_csr IN get_installbase_id_csr(p_instance_id => l_instance_id)
                           LOOP
                               l_installbase_id := l_installbase_id_csr.id;
                           END LOOP;
                           -- cursor to find serial no and quantiy
                           FOR l_sno_qty_csr IN get_sno_qty_csr(p_installbase_id => l_installbase_id)
                           LOOP
                               l_serial_number   := l_sno_qty_csr.sno;
                               l_quantity        := l_sno_qty_csr.qty;
                           END LOOP;
                           -- populates the tbl required for quote line details
                           IF(l_serial_number = x_tif_tbl(batch_offset).serial_number) THEN
                              lp_qld_tbl(qdt_counter).fin_line_id   := p_tif_tbl(batch_offset).asset_id;
                              lp_qld_tbl(qdt_counter).ib_line_id    := l_installbase_id;
                              lp_qld_tbl(qdt_counter).SELECT_YN    := 'Y';
                              EXIT;
                           END IF;
                       END LOOP;
                       -- populates the table required for quote line details
                       lp_qld_tbl(qdt_counter).qte_id             := lx_quot_rec.id;
                       lp_qld_tbl(qdt_counter).dnz_chr_id         := p_tif_tbl(batch_offset).contract_id;
                       lp_qld_tbl(qdt_counter).instance_quantity  := p_tif_tbl(batch_offset).units_to_terminate;
                       lp_qld_tbl(qdt_counter).qst_code           := lx_quot_rec.qst_code;
                       IF(lx_tqlv_tbl.COUNT>0) THEN
                          FOR j IN lx_tqlv_tbl.FIRST..lx_tqlv_tbl.LAST LOOP
                              IF(lp_qld_tbl(qdt_counter).fin_line_id = lx_tqlv_tbl(j).kle_id AND lx_tqlv_tbl(j).qlt_code = 'AMCFIA') THEN
                                 lp_qld_tbl(qdt_counter).tql_id               := lx_tqlv_tbl(j).id;
                                 EXIT;
                              END IF;
                          END LOOP;
                       END IF;
                       qdt_counter                                := qdt_counter+1;
                   --  added for non serialized
                   ELSE
                       l_msg_tbl(0).msg_text                 := 'quote created for transaction_number '||x_tif_tbl(batch_offset).transaction_number;
                       log_messages(log_msg_flag             => 'P',
                                    p_transaction_number     => x_tif_tbl(batch_offset).transaction_number,
                                    p_contract_number        => x_tif_tbl(batch_offset).contract_number,
                                    p_asset_number           => x_tif_tbl(batch_offset).asset_number,
                                    p_date_effective         => x_tif_tbl(batch_offset).date_effective_from,
                                    p_quote_type             => x_tif_tbl(batch_offset).quote_type_code,
                                    p_quote_reason           => x_tif_tbl(batch_offset).quote_reason_code,
                                    p_quote_number           => lx_quot_rec.quote_number,
                                    msg_tbl                  => l_msg_tbl );
                   END IF;
                   IF(batch_offset = p_record_number) THEN
                     IF(lp_qld_tbl.COUNT>0) THEN
                       -- calls the quote_line_dtls API to create quote line details for the serialized assets
                       OKL_AM_TERMNT_QUOTE_PUB.quote_line_dtls(p_api_version   => p_api_version,
                                                               p_init_msg_list => OKC_API.G_FALSE,
                                                               x_return_status => l_return_status,
                                                               x_msg_count     => x_msg_count,
                                                               x_msg_data      => x_msg_data,
                                                               p_qld_tbl       => lp_qld_tbl);
                       lp_qld_tbl.DELETE;
                      /* unwinding the messages from stack and keeping them in log*/
                      --PAGARG 23-Feb-05 instead of calling accounting util call local procedure
                      GET_ERROR_MESSAGE(l_error_msg_rec);
                       IF (l_error_msg_rec.COUNT > 0) THEN
                           l_det_msg_count := 0;
                           FOR m IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                           LOOP
                               IF(length(l_error_msg_rec(m))>0) THEN
                                  l_msg_tbl(l_det_msg_count).msg_text      :=  l_error_msg_rec(m);
                                  l_det_msg_count                          :=  l_det_msg_count+1;
                               END IF;
                           END LOOP;
                       END IF;
                       IF( l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                         batch_offset := p_batch_offset;
                         FOR i IN p_batch_offset..p_record_number LOOP
                             IF(x_tif_tbl(i).serial_number IS NOT NULL) THEN
                                --x_tif_tbl(i).status := 'ERROR';
                                -- error in quote details
                                l_msg_tbl(l_det_msg_count).msg_text   := 'quote created, error in quote details for transaction_number '||x_tif_tbl(i).transaction_number;
                                log_messages(log_msg_flag             => 'E',
                                             p_transaction_number     => x_tif_tbl(i).transaction_number,
                                             p_contract_number        => x_tif_tbl(i).contract_number,
                                             p_asset_number           => x_tif_tbl(i).asset_number,
                                             p_date_effective         => x_tif_tbl(i).date_effective_from,
                                             p_quote_type             => x_tif_tbl(i).quote_type_code,
                                             p_quote_reason           => x_tif_tbl(i).quote_reason_code,
                                             p_quote_number           => lx_quot_rec.quote_number,
                                             msg_tbl                  => l_msg_tbl );
                                -- since quote details is failed quote cannot be accepted changing l_accept_flag='N'
                                l_accept_flag := 'N';
                             END IF;
                         END LOOP;
                       ELSE
                         batch_offset := p_batch_offset;
                         FOR i IN p_batch_offset..p_record_number LOOP
                            IF(x_tif_tbl(i).serial_number IS NOT NULL) THEN
                               l_msg_tbl(0).msg_text    := 'quote and quote details created for transaction_number '||x_tif_tbl(i).transaction_number;
                               log_messages(log_msg_flag             => 'P',
                                            p_transaction_number     => x_tif_tbl(i).transaction_number,
                                            p_contract_number        => x_tif_tbl(i).contract_number,
                                            p_asset_number           => x_tif_tbl(i).asset_number,
                                            p_date_effective         => x_tif_tbl(i).date_effective_from,
                                            p_quote_type             => x_tif_tbl(i).quote_type_code,
                                            p_quote_reason           => x_tif_tbl(i).quote_reason_code,
                                            p_quote_number           => lx_quot_rec.quote_number,
                                            msg_tbl                  => l_msg_tbl );
                            END IF;
                         END LOOP;
                       END IF;
                     END IF; -- if(lp_qld_tbl >0)
                       EXIT;
                   END IF;
                 batch_offset := batch_offset+1;
            END LOOP;--for batch
          -- adding the code for accepting the quote
          IF(l_accept_flag = 'Y') THEN
             -- if any record which is part of this quote has auto_accept_yn='N'
             -- dont accept the quote
             FOR batch_offset IN p_batch_offset..p_record_number
             LOOP
                 IF(x_tif_tbl(batch_offset).auto_accept_yn = 'N') THEN
                    l_accept_flag := 'N';
                    EXIT;
                 END IF;
             END LOOP;
             -- accept the quote
             IF(l_accept_flag = 'Y') THEN
                lp_term_rec.id                := lx_quot_rec.id;
                lp_term_rec.accepted_yn       := 'Y';
                -- lp_term_rec.preproceeds_yn    := 'Y'; -- rmunjulu Bug 4239780 Should not set PreProceeds flag
                lp_term_rec.date_effective_to := lx_quot_rec.date_effective_to;
                -- calling the API to accept quote
                OKL_AM_TERMNT_QUOTE_PUB.terminate_quote (p_api_version                  => p_api_version,
                                                         p_init_msg_list                => OKL_API.G_FALSE,
                                                         x_return_status                => l_return_status,
                                                         x_msg_count                    => x_msg_count,
                                                         x_msg_data                     => x_msg_data,
                                                         p_term_rec                     => lp_term_rec,
                                                         x_term_rec                     => lx_term_rec,
                                                         x_err_msg                      => lx_err_msg);
                /* unwinding the messages from stack and keeping them in log*/
                --PAGARG 23-Feb-05 instead of calling accounting util call local procedure
                GET_ERROR_MESSAGE(l_error_msg_rec);
                IF (l_error_msg_rec.COUNT > 0) THEN
                    l_det_msg_count := 0;
                    FOR m IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                    LOOP
                       IF(length(l_error_msg_rec(m))>0) THEN
                          l_msg_tbl(l_det_msg_count).msg_text      :=  l_error_msg_rec(m);
                          l_det_msg_count                          :=  l_det_msg_count+1;
                       END IF;
                    END LOOP;
                END IF;
                IF( l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    FOR i IN p_batch_offset..p_record_number
                    LOOP
                        -- error in accepting quote
                        --l_msg_tbl(l_det_msg_count).msg_text   := 'error in acccepting quote for transaction_number '||x_tif_tbl(i).transaction_number;
                        log_messages(log_msg_flag             => 'E',
                                     p_transaction_number     => x_tif_tbl(i).transaction_number,
                                     p_contract_number        => x_tif_tbl(i).contract_number,
                                     p_asset_number           => x_tif_tbl(i).asset_number,
                                     p_date_effective         => x_tif_tbl(i).date_effective_from,
                                     p_quote_type             => x_tif_tbl(i).quote_type_code,
                                     p_quote_reason           => x_tif_tbl(i).quote_reason_code,
                                     p_quote_number           => lx_quot_rec.quote_number,
                                     msg_tbl                  => l_msg_tbl );
                    END LOOP;
                END IF;
             ELSE
                 -- quote can not be accepted as one line has auto_accept_yn = 'N'
                 l_msg_tbl(0).msg_text   := 'Quote '||lx_quot_rec.quote_number||' cannot be accepted as one of the transaction line contains auto_accept_yn as N';
                 FOR i IN p_batch_offset..p_record_number
                 LOOP
                     -- error in accepting quote
                     log_messages(log_msg_flag             => 'E',
                                  p_transaction_number     => x_tif_tbl(i).transaction_number,
                                  p_contract_number        => x_tif_tbl(i).contract_number,
                                  p_asset_number           => x_tif_tbl(i).asset_number,
                                  p_date_effective         => x_tif_tbl(i).date_effective_from,
                                  p_quote_type             => x_tif_tbl(i).quote_type_code,
                                  p_quote_reason           => x_tif_tbl(i).quote_reason_code,
                                  p_quote_number           => lx_quot_rec.quote_number,
                                  msg_tbl                  => l_msg_tbl );
                 END LOOP;
             END IF;
          END IF;
          -- end of auto accept logic
          ELSE
              FOR batch_offset IN p_batch_offset..p_record_number LOOP
                  -- updates status of all rows for which quote is not created.
                  x_tif_tbl(batch_offset).status := 'ERROR';
                  l_msg_tbl(l_qte_msg_count).msg_text   := 'quote not created for transaction_number '||x_tif_tbl(batch_offset).transaction_number;
                  log_messages(log_msg_flag             => 'V',
                               p_transaction_number     => x_tif_tbl(batch_offset).transaction_number,
                               p_contract_number        => x_tif_tbl(batch_offset).contract_number,
                               p_asset_number           => x_tif_tbl(batch_offset).asset_number,
                               p_date_effective         => x_tif_tbl(batch_offset).date_effective_from,
                               p_quote_type             => x_tif_tbl(batch_offset).quote_type_code,
                               p_quote_reason           => x_tif_tbl(batch_offset).quote_reason_code,
                               msg_tbl                  => l_msg_tbl );
              END LOOP;
          END IF;
    EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         l_msg_tbl(0).msg_text      := 'create_quote:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
    END create_quote;

      -- Start of comments
      --
      -- Procedure Name  : populate_quote
      -- Description     : This procedure populates the data required for calling
      --                 : create_termination_quote API and quote_line_details API
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tif_tbl
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      --                 : 14-MAR-03 RABHUPAT added another parameter to create_quote
      -- End of comments

    PROCEDURE populate_quote(
                            p_api_version    IN NUMBER,
                            p_init_msg_list  IN VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            p_tif_tbl        IN tif_tbl_type,
                            x_tif_tbl        OUT NOCOPY tif_tbl_type,
                            p_group_number   IN NUMBER
                            )IS
    l_tif_rec              tif_rec_type;
    lp_tif_tbl             tif_tbl_type;
    lx_tif_tbl             tif_tbl_type;
    lp_quot_rec            quot_rec_type;
    lx_quot_rec            quot_rec_type;
    lp_assn_tbl            assn_tbl_type;
    lx_assn_tbl            assn_tbl_type;
    lx_tqlv_tbl            tqlv_tbl_type;
    lp_qpyv_tbl            qpyv_tbl_type;
    lp_qld_tbl             qld_tbl_type;
    batch_offset           NUMBER;
    group_number           NUMBER;
    record_number          NUMBER;
    quote_lines            NUMBER;
    qdt_counter            NUMBER;
    l_installbase_id       NUMBER;
    l_instance_id          NUMBER;
    l_quote_success        NUMBER;
    i                      NUMBER;
    l_serial_number        l_tif_rec.serial_number%TYPE;
    l_quantity             l_tif_rec.units_to_terminate%TYPE;
    l_contract_number      l_tif_rec.contract_number%TYPE;
    l_quote_type           l_tif_rec.quote_type_code%TYPE;
    l_quote_reason         l_tif_rec.quote_reason_code%TYPE;
    l_date_effective_from  l_tif_rec.date_effective_from%TYPE;
    l_msg_tbl              msg_tbl_type;

    BEGIN
         record_number        := 0;
         quote_lines          := 0;
         batch_offset         := 0;
         group_number         := p_group_number;
         lp_tif_tbl           := p_tif_tbl;
         lx_tif_tbl           := p_tif_tbl;
         l_contract_number    := OKC_API.G_MISS_CHAR;
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF(p_tif_tbl.COUNT>0) THEN
       FOR record_number IN p_tif_tbl.FIRST..p_tif_tbl.LAST LOOP
       -- checking the condition to separate the batches for quote creation
          IF(((l_contract_number  <> p_tif_tbl(record_number).contract_number) OR
           (l_quote_type          <> p_tif_tbl(record_number).quote_type_code) OR
           (l_quote_reason        <> p_tif_tbl(record_number).quote_reason_code) OR
           (l_date_effective_from <> p_tif_tbl(record_number).date_effective_from))
           AND (record_number     <>p_tif_tbl.FIRST)) THEN
             -- populates the lp_quot_rec and calls create_quote
             lp_quot_rec.khr_id               := p_tif_tbl(record_number-1).contract_id;
             lp_quot_rec.date_effective_from  := p_tif_tbl(record_number-1).date_effective_from;
             lp_quot_rec.org_id               := p_tif_tbl(record_number-1).org_id;
             lp_quot_rec.qtp_code             := p_tif_tbl(record_number-1).quote_type_code;
             lp_quot_rec.qrs_code             := p_tif_tbl(record_number-1).quote_reason_code;
             create_quote(
                          p_api_version    => p_api_version
                         ,p_init_msg_list  => OKC_API.G_FALSE
                         ,x_msg_count      => x_msg_count
                         ,x_msg_data       => x_msg_data
                         ,x_return_status  => x_return_status
                         ,p_tif_tbl        => lp_tif_tbl
                         ,x_tif_tbl        => lx_tif_tbl
                         ,p_quot_rec       => lp_quot_rec
                         ,p_assn_tbl       => lp_assn_tbl
                         ,p_qpyv_tbl       => lp_qpyv_tbl
                         ,p_batch_offset   => batch_offset
                         ,p_record_number  => record_number-1);
             lp_assn_tbl.DELETE;
             lp_tif_tbl.DELETE;
             lp_tif_tbl := lx_tif_tbl;
             lx_tif_tbl.DELETE;
             FOR i IN batch_offset..record_number-1 LOOP
                 lp_tif_tbl(i).group_number := group_number;
             END LOOP;
             group_number := group_number+1;
             batch_offset := record_number;
             quote_lines  := 0;
          END IF;--not equal condition
             -- copy p_tif_tbl record in to local variables
             l_contract_number                := p_tif_tbl(record_number).contract_number;
             l_quote_type                     := p_tif_tbl(record_number).quote_type_code;
             l_quote_reason                   := p_tif_tbl(record_number).quote_reason_code;
             l_date_effective_from            := p_tif_tbl(record_number).date_effective_from;
          --assign values to assn_tbl;
          IF(lp_assn_tbl.COUNT>0) THEN
                IF(p_tif_tbl(record_number).asset_id = lp_assn_tbl(quote_lines).p_asset_id) THEN
                   lp_assn_tbl(quote_lines).p_quote_qty := lp_assn_tbl(quote_lines).p_quote_qty+p_tif_tbl(record_number).units_to_terminate;
                ELSE
                    quote_lines                              := quote_lines+1;
                    lp_assn_tbl(quote_lines).p_asset_id      := p_tif_tbl(record_number).asset_id;
                    lp_assn_tbl(quote_lines).p_asset_number  := p_tif_tbl(record_number).asset_number;
                    lp_assn_tbl(quote_lines).p_quote_qty     := p_tif_tbl(record_number).units_to_terminate;
                END IF;
          ELSE
             --assign values to assn_tbl
             lp_assn_tbl(quote_lines).p_asset_id     := p_tif_tbl(record_number).asset_id;
             lp_assn_tbl(quote_lines).p_asset_number := p_tif_tbl(record_number).asset_number;
             lp_assn_tbl(quote_lines).p_quote_qty    := p_tif_tbl(record_number).units_to_terminate;
          END IF;
          IF(record_number = p_tif_tbl.LAST) THEN
             -- populates the lp_quot_rec and calls create_quote for the last record
             lp_quot_rec.khr_id               := p_tif_tbl(record_number).contract_id;
             lp_quot_rec.date_effective_from  := p_tif_tbl(record_number).date_effective_from;
             lp_quot_rec.org_id               := p_tif_tbl(record_number).org_id;
             lp_quot_rec.qtp_code             := p_tif_tbl(record_number).quote_type_code;
             lp_quot_rec.qrs_code             := p_tif_tbl(record_number).quote_reason_code;
             create_quote(p_api_version    => p_api_version
                         ,p_init_msg_list  => OKC_API.G_FALSE
                         ,x_msg_count      => x_msg_count
                         ,x_msg_data       => x_msg_data
                         ,x_return_status  => x_return_status
                         ,p_tif_tbl        => lp_tif_tbl
                         ,x_tif_tbl        => lx_tif_tbl
                         ,p_quot_rec       => lp_quot_rec
                         ,p_assn_tbl       => lp_assn_tbl
                         ,p_qpyv_tbl       => lp_qpyv_tbl
                         ,p_batch_offset   => batch_offset
                         ,p_record_number  => record_number);
              FOR i IN batch_offset..record_number LOOP
                 lx_tif_tbl(i).group_number := group_number;
              END LOOP;
           END IF;
       END LOOP;--p_tif_tbl.FIRST..p_tif_tbl.LAST
       x_tif_tbl.DELETE;
       x_tif_tbl := lx_tif_tbl;
       IF (x_tif_tbl.COUNT>0) THEN
         -- updates the INTERFACE table
         FOR record_number IN x_tif_tbl.FIRST..x_tif_tbl.LAST LOOP
              update_row(p_api_version   => p_api_version
                        ,p_init_msg_list => OKC_API.G_FALSE
                        ,x_msg_data      => x_msg_data
                        ,x_msg_count     => x_msg_count
                        ,x_return_status => x_return_status
                        ,p_tif_rec       => x_tif_tbl(record_number));
          -- Save message from stack into transaction message table
          OKL_AM_UTIL_PVT.process_messages(p_trx_source_table   => 'OKL_TERMNT_INTERFACE',
                                           p_trx_id             => lx_tif_tbl(record_number).transaction_number,
                                           x_return_status      => x_return_status);
         END LOOP;
       END IF;
    END IF;--p_tif_tbl.COUNT>0 END IF; -- To check if table contains any record.
    EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         l_msg_tbl(0).msg_text                 := 'populate_quote:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END populate_quote;

/* RABHUPAT added party logic for termination interface logic, only recipient role can be overwritten not others
   and creates quote for each party record defaults the quote_role_code to 'RECIPIENT'*/

      -- Start of comments
      --
      -- Procedure Name  : validate_party
      -- Description     : This procedure validates the party table fields
      --                 :populates the data required for calling
      --                 : create_termination_quote API
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tip_tbl,p_tif_tbl
      -- Version         : 1.0
      -- History         : 14-MAR-03 RABHUPAT Created
      -- End of comments

PROCEDURE validate_party(p_api_version    IN NUMBER,
                         p_init_msg_list  IN VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         p_tif_tbl        IN tif_tbl_type,
                         x_tif_tbl        OUT NOCOPY tif_tbl_type,
                         p_tip_tbl        IN tip_tbl_type,
                         x_tip_tbl        OUT NOCOPY tip_tbl_type) IS

    -- cursor to retrive contract_id from OKL_TERMNT_INTERFACE joined by transaction_number
    CURSOR get_contract_id_csr(p_transaction_number IN NUMBER) IS
    SELECT contract_id,status
    FROM OKL_TERMNT_INTERFACE
    WHERE transaction_number = p_transaction_number;

    -- cursor to select the party details using contract_id and quote_role_code
   --Fixed Bug # 5484903
    CURSOR quote_party_details_csr(p_chr_id IN NUMBER, p_role_code IN VARCHAR2) IS
    SELECT id,object1_id1,object1_id2,jtot_object1_code
    FROM OKC_K_PARTY_ROLES_B
    WHERE  dnz_chr_id = p_chr_id
    AND chr_id = dnz_chr_id
    AND rle_code = p_role_code;
    -- cursor to select the party_name if party is VENDOR
    CURSOR get_vendor_info_csr(p_object1_id1 IN VARCHAR2, p_object1_id2 IN VARCHAR2) IS
    SELECT party_number,name
    FROM OKX_VENDORS_V
    WHERE id1 = p_object1_id1 AND id2 = p_object1_id2;

    -- cursor to select the party_name if party is LESSEE
    CURSOR get_lessee_info_csr(p_object1_id1 IN VARCHAR2, p_object1_id2 IN VARCHAR2) IS
    SELECT party_name,party_number,email_address
    FROM HZ_PARTIES
    WHERE ((party_id = p_object1_id1) AND party_type IN ( 'PERSON','ORGANIZATION'));

    l_count                  NUMBER;
    l_dup_flag               VARCHAR2(1);
    l_transaction_number     OKL_TERMNT_INTF_PTY.transaction_number%TYPE;
    l_chr_id                 NUMBER;
    lp_tip_tbl               tip_tbl_type;
    lx_tip_tbl               tip_tbl_type;
    l_qpy_id                 OKL_TERMNT_INTF_PTY.qpy_id%TYPE;
    l_party_object_id1       OKL_TERMNT_INTF_PTY.party_object_id1%TYPE;
    l_party_object_id2       OKL_TERMNT_INTF_PTY.party_object_id2%TYPE;
    l_party_object_code      OKL_TERMNT_INTF_PTY.party_object_code%TYPE;
    l_contract_party_number  OKL_TERMNT_INTF_PTY.contract_party_number%TYPE;
    l_contract_party_id      OKL_TERMNT_INTF_PTY.contract_party_id%TYPE;
    l_contract_party_name    OKL_TERMNT_INTF_PTY.contract_party_name%TYPE;
    l_email_address          OKL_TERMNT_INTF_PTY.email_address%TYPE;
    message                  VARCHAR2(200);
    l_msg_tbl                msg_tbl_type;
BEGIN
     x_tif_tbl       := p_tif_tbl;
     lp_tip_tbl      := p_tip_tbl;
     lx_tip_tbl      := p_tip_tbl;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     l_count         := 0;
     IF(lp_tip_tbl.COUNT>0) THEN
        -- sets the session variables
        FOR record_number IN lp_tip_tbl.FIRST..lp_tip_tbl.LAST LOOP
            -- populate WHO columns in party table
            lx_tip_tbl(record_number).CREATION_DATE            := SYSDATE;
            lx_tip_tbl(record_number).CREATED_BY               := FND_GLOBAL.USER_ID;
            l_dup_flag                                         := 'N';
            IF(l_transaction_number = lp_tip_tbl(record_number).transaction_number) THEN
               lx_tip_tbl(record_number).status := 'ERROR';
               l_dup_flag                       := 'Y';
               --transaction_number repeated, ERROR out only the party record not the INTERFACE record
               -- striked off in the DLD
               OKC_API.set_message(p_app_name      => g_app_name,
                                   p_msg_name      => 'OKL_AM_DUP_TRAN_NUM',
                                   p_token1        => 'TRANSACTION_NUMBER',
                                   p_token1_value  => lx_tip_tbl(record_number).transaction_number);
               message :='transaction_number '||lx_tip_tbl(record_number).transaction_number||' repeated in party table';
            ELSIF(lp_tip_tbl(record_number).contract_party_role IS NULL) THEN
                  lx_tip_tbl(record_number).status := 'ERROR';
                  -- contract_party_role should be entered
                  OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'OKC_CONTRACTS_REQUIRED_VALUE',
                                      p_token1        => 'COL_NAME',
                                      p_token1_value  => 'CONTRACT PARTY ROLE');
                  message :='contract party role should be entered for transaction_number '||lx_tip_tbl(record_number).transaction_number;
            ELSE
                 lx_tip_tbl(record_number).status := 'WORKING';
            END IF;
            IF(lx_tip_tbl(record_number).status <> 'ERROR') THEN
               l_transaction_number := lp_tip_tbl(record_number).transaction_number;
               l_chr_id             := NULL;
               -- fetches the associated contract_id from INTERFACE table based on transaction_number
               FOR interface_dtls IN get_contract_id_csr(l_transaction_number) LOOP
                   IF(interface_dtls.status <> 'WORKING') THEN
                      lx_tip_tbl(record_number).status := 'ERROR';
                      -- corresponding transaction_number in INTERFACE table is ERRORED out
                      -- striked off in the DLD
                      OKC_API.set_message(p_app_name      => g_app_name,
                                          p_msg_name      => 'OKL_AM_ERR_INTERFACE',
                                          p_token1        => 'TRANSACTION_NUMBER',
                                          p_token1_value  => lx_tip_tbl(record_number).transaction_number);
                      message :='transaction_number in OKL_TERMNT_INTERFACE is ERROR for transaction number '||lx_tip_tbl(record_number).transaction_number;
                   ELSE
                       l_chr_id := interface_dtls.contract_id;
                   END IF;
               END LOOP;
               IF(l_chr_id IS NULL OR l_chr_id = OKC_API.G_MISS_NUM)THEN
                  lx_tip_tbl(record_number).status := 'ERROR';
                  -- wrong transaction number
                  OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'OKL_AM_JOIN_MIS_MATCH',
                                      p_token1        => 'TRANSACTION_NUMBER',
                                      p_token1_value  => lx_tip_tbl(record_number).transaction_number);
                  message :='wrong transaction number '||lx_tip_tbl(record_number).transaction_number;
               END IF;
            END IF;
            -- if no role specified default it to RECIPIENT
            IF(lx_tip_tbl(record_number).status <> 'ERROR') THEN
               IF(lx_tip_tbl(record_number).quote_role_code IS NULL OR lx_tip_tbl(record_number).quote_role_code = OKC_API.G_MISS_CHAR) THEN
                  lx_tip_tbl(record_number).quote_role_code := 'RECIPIENT';
               END IF;
               IF(lx_tip_tbl(record_number).quote_role_code = 'RECIPIENT') THEN
                  -- retrive the quote_party information
                  l_count   := 0;
                  l_qpy_id  := NULL;
                  l_party_object_id1 := NULL;
                  l_party_object_id2 := NULL;
                  -- retrive quote party roles
                  FOR object_ids IN quote_party_details_csr(l_chr_id,lp_tip_tbl(record_number).contract_party_role) LOOP
                      l_qpy_id                  := object_ids.id;
                      l_party_object_id1        := object_ids.object1_id1;
                      l_party_object_id2        := object_ids.object1_id2;
                      l_party_object_code       := object_ids.jtot_object1_code;
                      l_count                   := l_count+1;
                      l_contract_party_number   := NULL;
                      /* If party is vendor */
                      IF(l_party_object_code = 'OKX_VENDOR') THEN
                         FOR vendor_dtls IN get_vendor_info_csr(l_party_object_id1, l_party_object_id2) LOOP
                             l_contract_party_number := vendor_dtls.party_number;
                             l_contract_party_id     := l_party_object_id1;
                             l_contract_party_name   := vendor_dtls.name;
                             -- populate all party details required
                             IF(lp_tip_tbl(record_number).contract_party_number = l_contract_party_number) THEN
                                lx_tip_tbl(record_number).qpy_id                  := l_qpy_id;
                                lx_tip_tbl(record_number).contract_party_id       := l_contract_party_id;
                                lx_tip_tbl(record_number).contract_party_name     := l_contract_party_name;
                                lx_tip_tbl(record_number).party_object_id1        := l_party_object_id1;
                                lx_tip_tbl(record_number).party_object_id2        := l_party_object_id2;
                                lx_tip_tbl(record_number).party_object_code       := l_party_object_code;
                                l_count                                           := -1;
                                EXIT;
                             ELSIF(lp_tip_tbl(record_number).contract_party_id = l_contract_party_id) THEN
                                   lx_tip_tbl(record_number).qpy_id                  := l_qpy_id;
                                   lx_tip_tbl(record_number).contract_party_number   := l_contract_party_number;
                                   lx_tip_tbl(record_number).contract_party_name     := l_contract_party_name;
                                   lx_tip_tbl(record_number).party_object_id1        := l_party_object_id1;
                                   lx_tip_tbl(record_number).party_object_id2        := l_party_object_id2;
                                   lx_tip_tbl(record_number).party_object_code       := l_party_object_code;
                                   l_count                                           := -1;
                                   EXIT;
                             END IF;
                         END LOOP;
                      /* If party is Lessee */
                      ELSIF(l_party_object_code = 'OKX_PARTY') THEN
                            FOR lessee_dtls IN get_lessee_info_csr(l_party_object_id1, l_party_object_id2) LOOP
                                l_contract_party_number := lessee_dtls.party_number;
                                l_contract_party_name   := lessee_dtls.party_name;
                                l_email_address         := lessee_dtls.email_address;
                                l_contract_party_id     := l_party_object_id1;
                                -- populate all party details required
                                IF(lp_tip_tbl(record_number).contract_party_number = l_contract_party_number) THEN
                                   lx_tip_tbl(record_number).qpy_id                  := l_qpy_id;
                                   lx_tip_tbl(record_number).contract_party_id       := l_contract_party_id;
                                   lx_tip_tbl(record_number).contract_party_name     := l_contract_party_name;
                                   lx_tip_tbl(record_number).email_address           := l_email_address;
                                   lx_tip_tbl(record_number).party_object_id1        := l_party_object_id1;
                                   lx_tip_tbl(record_number).party_object_id2        := l_party_object_id2;
                                   lx_tip_tbl(record_number).party_object_code       := l_party_object_code;
                                   l_count                                           := -1;
                                   EXIT;
                                ELSIF(lp_tip_tbl(record_number).contract_party_id = l_contract_party_id) THEN
                                      lx_tip_tbl(record_number).qpy_id                  := l_qpy_id;
                                      lx_tip_tbl(record_number).contract_party_number   := l_contract_party_number;
                                      lx_tip_tbl(record_number).contract_party_name     := l_contract_party_name;
                                      lx_tip_tbl(record_number).email_address           := l_email_address;
                                      lx_tip_tbl(record_number).party_object_id1        := l_party_object_id1;
                                      lx_tip_tbl(record_number).party_object_id2        := l_party_object_id2;
                                      lx_tip_tbl(record_number).party_object_code       := l_party_object_code;
                                      l_count                                           := -1;
                                      EXIT;
                                END IF;
                            END LOOP;
                      END IF;
                      IF(l_count = -1) THEN
                         EXIT;
                      END IF;
                  END LOOP;
                  IF(l_count = 0) THEN
                     lx_tip_tbl(record_number). status := 'ERROR';
                     -- neither lessee nor vendor
                     OKC_API.set_message(p_app_name      => g_app_name,
                                         p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                         p_token1        => 'COL_NAME',
                                         p_token1_value  => 'CONTRACT PARTY ROLE');
                     message :='quote party should be a lessee or vendor for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                  ELSIF(l_count>1) THEN
                        IF((lp_tip_tbl(record_number).contract_party_id IS NULL OR lp_tip_tbl(record_number).contract_party_id = OKC_API.G_MISS_NUM) AND
                           (lp_tip_tbl(record_number).contract_party_number IS NULL OR lp_tip_tbl(record_number).contract_party_number = OKC_API.G_MISS_CHAR)) THEN
                           lx_tip_tbl(record_number). status := 'ERROR';
                           -- neither contract_party_number nor contract_party_id are entered
                           OKC_API.set_message(p_app_name      => g_app_name,
                                               p_msg_name      => 'OKC_CONTRACTS_REQUIRED_VALUE',
                                               p_token1        => 'COL_NAME',
                                               p_token1_value  => 'CONTRACT_PARTY_NAME OR PARTY_ID');
                           message :='contract_party_number or contract_party_id should be entered for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                        ELSIF(lp_tip_tbl(record_number).contract_party_number IS NOT NULL) THEN
                              IF(l_contract_party_number <> lp_tip_tbl(record_number).contract_party_number) THEN
                                 lx_tip_tbl(record_number). status := 'ERROR';
                                  -- contract party number entered is not valid
                                 OKC_API.set_message(p_app_name      => g_app_name,
                                                     p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                                     p_token1        => 'COL_NAME',
                                                     p_token1_value  => 'CONTRACT_PARTY_NUMBER');
                                 message :='contract party number entered not exists for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                              END IF;
                        ELSIF(lp_tip_tbl(record_number).contract_party_id IS NOT NULL) THEN
                              IF(l_contract_party_id <> lp_tip_tbl(record_number).contract_party_id) THEN
                                 lx_tip_tbl(record_number). status := 'ERROR';
                                 -- contract party id entered is not valid
                                 OKC_API.set_message(p_app_name      => g_app_name,
                                                     p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                                     p_token1        => 'COL_NAME',
                                                     p_token1_value  => 'CONTRACT_PARTY_NUMBER');
                                 message :='contract party id entered not exists for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                              END IF;
                        END IF;
                  ELSIF(l_count = 1) THEN
                        -- if only one party is associated then assign those parties even the user not entered
                        IF((lp_tip_tbl(record_number).contract_party_id IS NULL OR lp_tip_tbl(record_number).contract_party_id = OKC_API.G_MISS_NUM) AND
                           (lp_tip_tbl(record_number).contract_party_number IS NULL OR lp_tip_tbl(record_number).contract_party_number = OKC_API.G_MISS_CHAR)) THEN
                            lx_tip_tbl(record_number).qpy_id                  := l_qpy_id;
                            lx_tip_tbl(record_number).contract_party_number   := l_contract_party_number;
                            lx_tip_tbl(record_number).contract_party_id       := l_contract_party_id;
                            lx_tip_tbl(record_number).contract_party_name     := l_contract_party_name;
                            lx_tip_tbl(record_number).email_address           := l_email_address;
                            lx_tip_tbl(record_number).party_object_id1        := l_party_object_id1;
                            lx_tip_tbl(record_number).party_object_id2        := l_party_object_id2;
                            lx_tip_tbl(record_number).party_object_code       := l_party_object_code;
                        ELSIF(lp_tip_tbl(record_number).contract_party_number IS NOT NULL) THEN
                              IF(l_contract_party_number <> lp_tip_tbl(record_number).contract_party_number) THEN
                                 lx_tip_tbl(record_number). status := 'ERROR';
                                  -- contract party number entered is not valid
                                  OKC_API.set_message(p_app_name      => g_app_name,
                                                      p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                                      p_token1        => 'COL_NAME',
                                                      p_token1_value  => 'CONTRACT_PARTY_NUMBER');
                                  message :='contract party number entered not exists for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                              END IF;
                        ELSIF(lp_tip_tbl(record_number).contract_party_id IS NOT NULL) THEN
                              IF(l_contract_party_id <> lp_tip_tbl(record_number).contract_party_id) THEN
                                 lx_tip_tbl(record_number). status := 'ERROR';
                                 -- contract party id entered is not valid
                                 OKC_API.set_message(p_app_name      => g_app_name,
                                                     p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                                     p_token1        => 'COL_NAME',
                                                     p_token1_value  => 'CONTRACT_PARTY_NUMBER');
                                 message :='contract party id entered not exists for transaction_number '||lx_tip_tbl(record_number).transaction_number;
                              END IF;
                        END IF;
                  END IF;
               ELSE
                   lx_tip_tbl(record_number).status   := 'ERROR';
                   -- not recipient
                   OKC_API.set_message(p_app_name      => g_app_name,
                                       p_msg_name      => 'OKC_CONTRACTS_INVALID_VALUE',
                                       p_token1        => 'COL_NAME',
                                       p_token1_value  => 'QUOTE_ROLE_CODE');
                   message :='quote party type allowed is only RECIPIENT for transaction_number'||lx_tip_tbl(record_number).transaction_number;
               END IF;
            END IF;-- for cursor object_ids
            -- if party record is error make related record in INTERFACE table also ERROR, but not when duplicate record found
            IF(lx_tip_tbl(record_number).status = 'ERROR' AND l_dup_flag = 'N') THEN
               IF(x_tif_tbl.COUNT>0) THEN
                  FOR term_rec IN x_tif_tbl.FIRST..x_tif_tbl.LAST
                  LOOP
                      IF(x_tif_tbl(term_rec).transaction_number = lx_tip_tbl(record_number).transaction_number) THEN
                         x_tif_tbl(term_rec).status := 'ERROR';
                         l_msg_tbl(0).msg_text      := message;
                         log_messages(log_msg_flag             => 'V',
                                       p_transaction_number     => x_tif_tbl(term_rec).transaction_number,
                                       p_contract_number        => x_tif_tbl(term_rec).contract_number,
                                       p_asset_number           => x_tif_tbl(term_rec).asset_number,
                                       p_date_effective         => x_tif_tbl(term_rec).date_effective_from,
                                       p_quote_type             => x_tif_tbl(term_rec).quote_type_code,
                                       p_quote_reason           => x_tif_tbl(term_rec).quote_reason_code,
                                       msg_tbl                  => l_msg_tbl );

                         EXIT;
                      END IF;
                  END LOOP;
               END IF;
            END IF;
        END LOOP;
     END IF;
     x_tip_tbl := lx_tip_tbl;
EXCEPTION
        WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                            p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                            p_token2_value  => sqlerrm);
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        l_msg_tbl(0).msg_text    := 'validate_party:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
        log_messages(log_msg_flag             => 'V',
                     msg_tbl                  => l_msg_tbl );
END validate_party;

      -- Start of comments
      --
      -- Procedure Name  : update_party
      -- Description     : This procedure updates the party table fields
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tip_tbl,p_tif_tbl
      -- Version         : 1.0
      -- History         : 14-MAR-03 RABHUPAT Created
      -- End of comments

PROCEDURE update_party(p_api_version    IN NUMBER,
                       p_init_msg_list  IN VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2,
                       x_return_status  OUT NOCOPY VARCHAR2,
                       p_tip_rec        IN tip_rec_type) IS
    l_api_version            CONSTANT NUMBER       := p_api_version;
    l_api_name               CONSTANT VARCHAR2(30) := 'terminate_interface';
    l_return_status          VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
    l_msg_tbl                msg_tbl_type;
    BEGIN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
        --Check API version, initialize message list and create savepoint.
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
    -- updates the party table
    UPDATE  OKL_TERMNT_INTF_PTY
    SET
       OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_ID                = p_tip_rec.contract_party_id,
       OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_ROLE              = p_tip_rec.contract_party_role,
       OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_NAME              = p_tip_rec.contract_party_name,
       OKL_TERMNT_INTF_PTY.CONTRACT_PARTY_NUMBER            = p_tip_rec.contract_party_number,
       OKL_TERMNT_INTF_PTY.PARTY_OBJECT_CODE                = p_tip_rec.party_object_code,
       OKL_TERMNT_INTF_PTY.PARTY_OBJECT_ID1                 = p_tip_rec.party_object_id1,
       OKL_TERMNT_INTF_PTY.PARTY_OBJECT_ID2                 = p_tip_rec.party_object_id2,
       OKL_TERMNT_INTF_PTY.EMAIL_ADDRESS                    = p_tip_rec.email_address,
       OKL_TERMNT_INTF_PTY.ALLOCATION_PERCENTAGE            = p_tip_rec.allocation_percentage,
       OKL_TERMNT_INTF_PTY.DELAY_DAYS                       = p_tip_rec.delay_days,
       OKL_TERMNT_INTF_PTY.QPY_ID                           = p_tip_rec.qpy_id,
       OKL_TERMNT_INTF_PTY.TRANSACTION_NUMBER               = p_tip_rec.transaction_number,
       OKL_TERMNT_INTF_PTY.STATUS                           = p_tip_rec.status,
       OKL_TERMNT_INTF_PTY.REQUEST_ID                       = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1, NULL,FND_GLOBAL.CONC_REQUEST_ID),p_tip_rec.request_id),
       OKL_TERMNT_INTF_PTY.PROGRAM_APPLICATION_ID           = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),p_tip_rec.program_application_id),
       OKL_TERMNT_INTF_PTY.PROGRAM_ID                       = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),p_tip_rec.program_id),
       OKL_TERMNT_INTF_PTY.PROGRAM_UPDATE_DATE              = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,p_tip_rec.program_update_date,SYSDATE),
       OKL_TERMNT_INTF_PTY.ATTRIBUTE_CATEGORY               = p_tip_rec.attribute_category,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE1                       = p_tip_rec.attribute1,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE2                       = p_tip_rec.attribute2,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE3                       = p_tip_rec.attribute3,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE4                       = p_tip_rec.attribute4,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE5                       = p_tip_rec.attribute5,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE6                       = p_tip_rec.attribute6,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE7                       = p_tip_rec.attribute7,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE8                       = p_tip_rec.attribute8,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE9                       = p_tip_rec.attribute9,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE10                      = p_tip_rec.attribute10,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE11                      = p_tip_rec.attribute11,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE12                      = p_tip_rec.attribute12,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE13                      = p_tip_rec.attribute13,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE14                      = p_tip_rec.attribute14,
       OKL_TERMNT_INTF_PTY.ATTRIBUTE15                      = p_tip_rec.attribute15,
       OKL_TERMNT_INTF_PTY.CREATED_BY                       = p_tip_rec.created_by,
       OKL_TERMNT_INTF_PTY.CREATION_DATE                    = p_tip_rec.creation_date,
       OKL_TERMNT_INTF_PTY.LAST_UPDATED_BY                  = FND_GLOBAL.USER_ID,
       OKL_TERMNT_INTF_PTY.LAST_UPDATE_DATE                 = SYSDATE,
       OKL_TERMNT_INTF_PTY.LAST_UPDATE_LOGIN                = FND_GLOBAL.LOGIN_ID,
       OKL_TERMNT_INTF_PTY.QUOTE_ROLE_CODE                  = p_tip_rec.quote_role_code
    WHERE
         OKL_TERMNT_INTF_PTY.ROWID =p_tip_rec.row_id;

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        x_return_status := l_return_status;
EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
          x_return_status := OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                       G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_ERROR',
                                                       x_msg_count,
                                                       x_msg_data,
                                                      '_PVT');
        -- for unexpected error
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                      G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                      x_msg_count,
                                                      x_msg_data,
                                                      '_PVT');
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         l_msg_tbl(0).msg_text    := 'update_party:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
END update_party;

      -- Start of comments
      --
      -- Procedure Name  : select_party_info
      -- Description     : This procedure retrives the data from database
      --                 : based on status and updates the party table fields
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tip_tbl,p_pty_status
      -- Version         : 1.0
      -- History         : 14-MAR-03 RABHUPAT Created
      -- End of comments

PROCEDURE select_party_info(
                            p_api_version    IN NUMBER,
                            p_init_msg_list  IN VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_return_status  OUT NOCOPY VARCHAR2,
                            p_tip_tbl        IN tip_tbl_type,
                            x_tip_tbl        OUT NOCOPY tip_tbl_type,
                            p_pty_status     IN VARCHAR2
                            ) IS
    record_number            NUMBER;
    l_msg_tbl                msg_tbl_type;
    /* this cursor rearranges the data by using the columns contract_number,
       quote_type_code, quote_reason_code and asset_id */
CURSOR intface_pty_csr(p_status IN VARCHAR2) IS
SELECT
     ROWID
    ,CONTRACT_PARTY_ID
    ,CONTRACT_PARTY_ROLE
    ,CONTRACT_PARTY_NAME
    ,CONTRACT_PARTY_NUMBER
    ,PARTY_OBJECT_CODE
    ,PARTY_OBJECT_ID1
    ,PARTY_OBJECT_ID2
    ,EMAIL_ADDRESS
    ,ALLOCATION_PERCENTAGE
    ,DELAY_DAYS
    ,QPY_ID
    ,TRANSACTION_NUMBER
    ,STATUS
    ,REQUEST_ID
    ,PROGRAM_APPLICATION_ID
    ,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,ATTRIBUTE_CATEGORY
    ,ATTRIBUTE1
    ,ATTRIBUTE2
    ,ATTRIBUTE3
    ,ATTRIBUTE4
    ,ATTRIBUTE5
    ,ATTRIBUTE6
    ,ATTRIBUTE7
    ,ATTRIBUTE8
    ,ATTRIBUTE9
    ,ATTRIBUTE10
    ,ATTRIBUTE11
    ,ATTRIBUTE12
    ,ATTRIBUTE13
    ,ATTRIBUTE14
    ,ATTRIBUTE15
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,QUOTE_ROLE_CODE
FROM OKL_TERMNT_INTF_PTY
WHERE STATUS = P_STATUS
ORDER BY TRANSACTION_NUMBER;

BEGIN
     record_number:=0;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF (p_tip_tbl.COUNT > 0) THEN
         record_number := p_tip_tbl.FIRST;
         -- loops throught the table of records to update the values
         LOOP
           update_party(p_api_version   => p_api_version
                       ,p_init_msg_list => OKC_API.G_FALSE
                       ,x_msg_data      => x_msg_data
                       ,x_msg_count     => x_msg_count
                       ,x_return_status => x_return_status
                       ,p_tip_rec       => p_tip_tbl(record_number));
           EXIT WHEN (record_number = p_tip_tbl.LAST);
           record_number := p_tip_tbl.NEXT(record_number);
         END LOOP;
     END IF;
     record_number:=0;
     x_tip_tbl.DELETE;
     -- cursor to retrive the data from party table
     FOR party_rec IN intface_pty_csr(p_status => p_pty_status) LOOP
        x_tip_tbl(record_number).row_id                         :=  party_rec.rowid;
        x_tip_tbl(record_number).contract_party_id              :=  party_rec.contract_party_id;
        x_tip_tbl(record_number).contract_party_role            :=  party_rec.contract_party_role;
        x_tip_tbl(record_number).contract_party_name            :=  party_rec.contract_party_name;
        x_tip_tbl(record_number).contract_party_number          :=  party_rec.contract_party_number;
        x_tip_tbl(record_number).party_object_code              :=  party_rec.party_object_code;
        x_tip_tbl(record_number).party_object_id1               :=  party_rec.party_object_id1;
        x_tip_tbl(record_number).party_object_id2               :=  party_rec.party_object_id2;
        x_tip_tbl(record_number).email_address                  :=  party_rec.email_address;
        x_tip_tbl(record_number).allocation_percentage          :=  party_rec.allocation_percentage;
        x_tip_tbl(record_number).delay_days                     :=  party_rec.delay_days;
        x_tip_tbl(record_number).qpy_id                         :=  party_rec.qpy_id;
        x_tip_tbl(record_number).transaction_number             :=  party_rec.transaction_number;
        x_tip_tbl(record_number).status                         :=  party_rec.status;
        x_tip_tbl(record_number).request_id                     :=  party_rec.request_id;
        x_tip_tbl(record_number).program_application_id         :=  party_rec.program_application_id;
        x_tip_tbl(record_number).program_id                     :=  party_rec.program_id;
        x_tip_tbl(record_number).program_update_date            :=  party_rec.program_update_date;
        x_tip_tbl(record_number).attribute_category             :=  party_rec.attribute_category;
        x_tip_tbl(record_number).attribute1                     :=  party_rec.attribute1;
        x_tip_tbl(record_number).attribute2                     :=  party_rec.attribute2;
        x_tip_tbl(record_number).attribute3                     :=  party_rec.attribute3;
        x_tip_tbl(record_number).attribute4                     :=  party_rec.attribute4;
        x_tip_tbl(record_number).attribute5                     :=  party_rec.attribute5;
        x_tip_tbl(record_number).attribute6                     :=  party_rec.attribute6;
        x_tip_tbl(record_number).attribute7                     :=  party_rec.attribute7;
        x_tip_tbl(record_number).attribute8                     :=  party_rec.attribute8;
        x_tip_tbl(record_number).attribute9                     :=  party_rec.attribute9;
        x_tip_tbl(record_number).attribute10                    :=  party_rec.attribute10;
        x_tip_tbl(record_number).attribute11                    :=  party_rec.attribute11;
        x_tip_tbl(record_number).attribute12                    :=  party_rec.attribute12;
        x_tip_tbl(record_number).attribute13                    :=  party_rec.attribute13;
        x_tip_tbl(record_number).attribute14                    :=  party_rec.attribute14;
        x_tip_tbl(record_number).attribute15                    :=  party_rec.attribute15;
        x_tip_tbl(record_number).created_by                     :=  party_rec.created_by;
        x_tip_tbl(record_number).creation_date                  :=  party_rec.creation_date;
        x_tip_tbl(record_number).last_updated_by                :=  party_rec.last_updated_by;
        x_tip_tbl(record_number).last_update_date               :=  party_rec.last_update_date;
        x_tip_tbl(record_number).last_update_login              :=  party_rec.last_update_login;
        x_tip_tbl(record_number).quote_role_code                :=  party_rec.quote_role_code;
        record_number                                           :=  record_number+1;
     END LOOP;
EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                             p_msg_name      => g_unexpected_error,
                             p_token1        => g_sqlcode_token,
                             p_token1_value  => sqlcode,
                             p_token2        => g_sqlerrm_token,
                             p_token2_value  => sqlerrm);
         l_msg_tbl(0).msg_text                := 'select_party_info:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END select_party_info;

      -- Start of comments
      --
      -- Procedure Name  : populate_party_for_quote
      -- Description     : This procedure populates the party information
      --                 : and creates the quote
      -- Business Rules  :
      -- Parameters      : Input parameters : p_tip_tbl,p_tif_tbl
      -- Version         : 1.0
      -- History         : 14-MAR-03 RABHUPAT Created
      -- End of comments

PROCEDURE populate_party_for_quote(p_api_version    IN NUMBER,
                                   p_init_msg_list  IN VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   p_tip_tbl        IN tip_tbl_type,
                                   p_tif_tbl        IN tif_tbl_type,
                                   x_tif_tbl        OUT NOCOPY tif_tbl_type,
                                   x_group_number   OUT NOCOPY NUMBER) IS
     l_tip_rec              tip_rec_type;
     lp_tif_tbl             tif_tbl_type;
     lx_tif_tbl             tif_tbl_type;
     lp_quot_rec            quot_rec_type;
     lx_quot_rec            quot_rec_type;
     lp_assn_tbl            assn_tbl_type;
     lx_assn_tbl            assn_tbl_type;
     lx_tqlv_tbl            tqlv_tbl_type;
     lp_qpyv_tbl            qpyv_tbl_type;
     lx_qpyv_tbl            qpyv_tbl_type;
     x_q_party_uv_tbl       OKL_AM_PARTIES_PVT.q_party_uv_tbl_type;
     l_msg_tbl              msg_tbl_type;
     x_record_count         NUMBER;
BEGIN
     lp_tif_tbl  := p_tif_tbl;
     x_group_number  := 0;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     IF(p_tip_tbl.COUNT>0) THEN
        -- populating the values required to create_quote
        FOR party_rec IN p_tip_tbl.FIRST..p_tip_tbl.LAST
        LOOP
            l_tip_rec :=p_tip_tbl(party_rec);
            IF(lp_tif_tbl.COUNT>0) THEN
               FOR term_rec IN lp_tif_tbl.FIRST..lp_tif_tbl.LAST
               LOOP
                   -- populates quot_rec and assn_tbl
                   IF(p_tip_tbl(party_rec).transaction_number = lp_tif_tbl(term_rec).transaction_number) THEN
                      -- set the group number
                      lp_tif_tbl(term_rec).group_number      := x_group_number;
                      x_group_number                         := x_group_number+1;
                      -- populate quot_rec
                      lp_quot_rec.khr_id                     := lp_tif_tbl(term_rec).contract_id;
                      lp_quot_rec.date_effective_from        := lp_tif_tbl(term_rec).date_effective_from;
                      lp_quot_rec.org_id                     := lp_tif_tbl(term_rec).org_id;
                      lp_quot_rec.qtp_code                   := lp_tif_tbl(term_rec).quote_type_code;
                      lp_quot_rec.qrs_code                   := lp_tif_tbl(term_rec).quote_reason_code;
                      --populate assn_tbl
                      lp_assn_tbl(0).p_asset_id              := lp_tif_tbl(term_rec).asset_id;
                      lp_assn_tbl(0).p_asset_number          := lp_tif_tbl(term_rec).asset_number;
                      lp_assn_tbl(0).p_quote_qty             := lp_tif_tbl(term_rec).units_to_terminate;
                      -- populate all the five default options and override the RECIPIENT
                      OKL_AM_PARTIES_PVT.fetch_rule_quote_parties (p_api_version    => p_api_version,
                                                                   p_init_msg_list  => OKC_API.G_FALSE,
                                                                   x_msg_count      => x_msg_count,
                                                                   x_msg_data       => x_msg_data,
                                                                   x_return_status  => x_return_status,
                                                                   p_qtev_rec       => lp_quot_rec,
                                                                   x_qpyv_tbl       => lp_qpyv_tbl,
                                                                   x_record_count   => x_record_count,
                                                                   x_q_party_uv_tbl => x_q_party_uv_tbl);
                      -- populates qpyv_tbl
                      IF(lp_qpyv_tbl.COUNT>0) THEN
                         FOR rule_party IN lp_qpyv_tbl.FIRST..lp_qpyv_tbl.LAST
                         LOOP
                             IF(lp_qpyv_tbl(rule_party).qpt_code = l_tip_rec.quote_role_code) THEN
                                lp_qpyv_tbl(rule_party).party_jtot_object1_code := l_tip_rec.party_object_code;
                                lp_qpyv_tbl(rule_party).party_object1_id1       := l_tip_rec.party_object_id1;
                                lp_qpyv_tbl(rule_party).party_object1_id2       := l_tip_rec.party_object_id2;
                                lp_qpyv_tbl(rule_party).cpl_id                  := l_tip_rec.qpy_id;
                             END IF;
                         END LOOP;
                      END IF;
                      -- calls Create quote parties with p_validate_only = TRUE
                      OKL_AM_PARTIES_PVT.create_quote_parties (
                                                               p_qtev_rec         =>   lp_quot_rec,
                                                               p_qpyv_tbl         =>   lp_qpyv_tbl,
                                                               p_validate_only    =>   TRUE,
                                                               x_qpyv_tbl         =>   lx_qpyv_tbl,
                                                               x_return_status    =>   x_return_status);
                      IF(x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                         lx_tif_tbl.DELETE;
                        -- create quote and quote_details
                            create_quote(p_api_version    => p_api_version
                                        ,p_init_msg_list  => OKC_API.G_FALSE
                                        ,x_msg_count      => x_msg_count
                                        ,x_msg_data       => x_msg_data
                                        ,x_return_status  => x_return_status
                                        ,p_tif_tbl        => lp_tif_tbl
                                        ,x_tif_tbl        => lx_tif_tbl
                                        ,p_quot_rec       => lp_quot_rec
                                        ,p_assn_tbl       => lp_assn_tbl
                                        ,p_qpyv_tbl       => lp_qpyv_tbl -- add it in create_quote also
                                        ,p_batch_offset   => term_rec
                                        ,p_record_number  => term_rec);
                      ELSE
                             lp_tif_tbl(term_rec).status := 'ERROR';
                      END IF;
                      -- update party record and interface record with values returned from create_quote
                      IF(lx_tif_tbl(term_rec).status = 'PROCESSED') THEN
                         l_tip_rec.status   :='PROCESSED';
                         lp_tif_tbl(term_rec) := lx_tif_tbl(term_rec);
                      ELSE
                            l_tip_rec.status  :='ERROR';
                            -- quote not created for transaction_number
                      END IF;
                      --updates the party table
                      update_party(p_api_version    => p_api_version
                                  ,p_init_msg_list => OKC_API.G_FALSE
                                  ,x_msg_data      => x_msg_data
                                  ,x_msg_count     => x_msg_count
                                  ,x_return_status => x_return_status
                                  ,p_tip_rec       => l_tip_rec);
                      EXIT;
                   END IF;
               END LOOP;
            END IF;
        END LOOP;
     END IF;
     x_tif_tbl := lp_tif_tbl;
EXCEPTION
         WHEN OTHERS THEN
         -- store SQL error message on message stack for caller
         OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => g_unexpected_error,
                              p_token1        => g_sqlcode_token,
                              p_token1_value  => sqlcode,
                              p_token2        => g_sqlerrm_token,
                              p_token2_value  => sqlerrm);
         l_msg_tbl(0).msg_text                := 'populate_party_for_quote:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
         log_messages(log_msg_flag             => 'V',
                      msg_tbl                  => l_msg_tbl );
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END populate_party_for_quote;
/*PARTY_LOGIC END*/


      -- Start of comments
      --
      -- Procedure Name  : termination_interface
      -- Description     : This is the only public procedure and calls all the
      --                 : required procedures to generate a quote
      -- Business Rules  :
      -- Parameters      : Input parameters : p_api_version, p_init_msg_list
      -- Version         : 1.0
      -- History         : 04-FEB-03 RABHUPAT Created
      --                 : 14-MAR-03 RABHUPAT added calls for party logic procedures
      -- End of comments

    PROCEDURE termination_interface(p_api_version    IN NUMBER,
                                    p_init_msg_list  IN VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    err_buf          OUT NOCOPY VARCHAR2,
                                    ret_code         OUT NOCOPY NUMBER)
    IS

    -- this cursor selects the rows with status as 'ENTERED' and orders by group_number
    CURSOR get_termnt_intface_dtls_csr(p_status IN VARCHAR2) IS
    SELECT
       ROWID
      ,TRANSACTION_NUMBER
      ,BATCH_NUMBER
      ,CONTRACT_ID
      ,CONTRACT_NUMBER
      ,ASSET_ID
      ,ASSET_NUMBER
      ,ASSET_DESCRIPTION
      ,SERIAL_NUMBER
      ,ORIG_SYSTEM
      ,ORIG_SYSTEM_REFERENCE
      ,UNITS_TO_TERMINATE
      ,COMMENTS
      ,DATE_PROCESSED
      ,DATE_EFFECTIVE_FROM
      ,TERMINATION_NOTIFICATION_EMAIL
      ,TERMINATION_NOTIFICATION_YN
      ,AUTO_ACCEPT_YN
      ,QUOTE_TYPE_CODE
      ,QUOTE_REASON_CODE
      ,QTE_ID
      ,STATUS
      ,ORG_ID
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,PROGRAM_UPDATE_DATE
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,GROUP_NUMBER
    FROM OKL_TERMNT_INTERFACE
    WHERE status = p_status
    ORDER BY CONTRACT_NUMBER;

    l_api_version            CONSTANT NUMBER       := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'terminate_interface';
    l_return_status          VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
    record_number            NUMBER;
    x_installbase_id         NUMBER;
    l_sys_date               DATE;
    l_tif_tbl                tif_tbl_type;
    lx_tif_tbl               tif_tbl_type;
    l_tip_tbl                tip_tbl_type;
    lx_tip_tbl               tip_tbl_type;
    l_group_number           NUMBER                := 0;
    tot_rec_processed        NUMBER                := 0;
    l_msg_tbl                msg_tbl_type;
    BEGIN

       x_return_status := OKC_API.G_RET_STS_SUCCESS;
        --Check API version, initialize message list and create savepoint.
        l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  '_PVT',
                                                  x_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -- this retrives the sysdate and passes to a local variable
        SELECT trunc(SYSDATE) INTO l_sys_date FROM DUAL;
        record_number:=0;

        -- loops through the records to populate the plsql table
        FOR termnt_rec IN get_termnt_intface_dtls_csr(p_status=>'ENTERED')
        LOOP
        l_tif_tbl(record_number).row_id                          :=  termnt_rec.rowid;
        l_tif_tbl(record_number).transaction_number              :=  termnt_rec.transaction_number;
        l_tif_tbl(record_number).batch_number                    :=  termnt_rec.batch_number;
        l_tif_tbl(record_number).contract_id                     :=  termnt_rec.contract_id;
        l_tif_tbl(record_number).contract_number                 :=  termnt_rec.contract_number;
        l_tif_tbl(record_number).asset_id                        :=  termnt_rec.asset_id;
        l_tif_tbl(record_number).asset_number                    :=  termnt_rec.asset_number;
        l_tif_tbl(record_number).asset_description               :=  termnt_rec.asset_description;
        l_tif_tbl(record_number).serial_number                   :=  termnt_rec.serial_number;
        l_tif_tbl(record_number).orig_system                     :=  termnt_rec.orig_system;
        l_tif_tbl(record_number).orig_system_reference           :=  termnt_rec.orig_system_reference;
        l_tif_tbl(record_number).units_to_terminate              :=  termnt_rec.units_to_terminate;
        l_tif_tbl(record_number).comments                        :=  termnt_rec.comments;
        l_tif_tbl(record_number).date_processed                  :=  termnt_rec.date_processed;
        l_tif_tbl(record_number).date_effective_from             :=  termnt_rec.date_effective_from;
        l_tif_tbl(record_number).termination_notification_email  :=  termnt_rec.termination_notification_email;
        l_tif_tbl(record_number).termination_notification_yn     :=  termnt_rec.termination_notification_yn;
        l_tif_tbl(record_number).auto_accept_yn                  :=  termnt_rec.auto_accept_yn;
        l_tif_tbl(record_number).quote_type_code                 :=  termnt_rec.quote_type_code;
        l_tif_tbl(record_number).quote_reason_code               :=  termnt_rec.quote_reason_code;
        l_tif_tbl(record_number).qte_id                          :=  termnt_rec.qte_id;
        l_tif_tbl(record_number).status                          :=  termnt_rec.status;
        l_tif_tbl(record_number).org_id                          :=  termnt_rec.org_id;
        l_tif_tbl(record_number).request_id                      :=  termnt_rec.request_id;
        l_tif_tbl(record_number).program_application_id          :=  termnt_rec.program_application_id;
        l_tif_tbl(record_number).program_id                      :=  termnt_rec.program_id;
        l_tif_tbl(record_number).program_update_date             :=  termnt_rec.program_update_date;
        l_tif_tbl(record_number).attribute_category              :=  termnt_rec.attribute_category;
        l_tif_tbl(record_number).attribute1                      :=  termnt_rec.attribute1;
        l_tif_tbl(record_number).attribute2                      :=  termnt_rec.attribute2;
        l_tif_tbl(record_number).attribute3                      :=  termnt_rec.attribute3;
        l_tif_tbl(record_number).attribute4                      :=  termnt_rec.attribute4;
        l_tif_tbl(record_number).attribute5                      :=  termnt_rec.attribute5;
        l_tif_tbl(record_number).attribute6                      :=  termnt_rec.attribute6;
        l_tif_tbl(record_number).attribute7                      :=  termnt_rec.attribute7;
        l_tif_tbl(record_number).attribute8                      :=  termnt_rec.attribute8;
        l_tif_tbl(record_number).attribute9                      :=  termnt_rec.attribute9;
        l_tif_tbl(record_number).attribute10                     :=  termnt_rec.attribute10;
        l_tif_tbl(record_number).attribute11                     :=  termnt_rec.attribute11;
        l_tif_tbl(record_number).attribute12                     :=  termnt_rec.attribute12;
        l_tif_tbl(record_number).attribute13                     :=  termnt_rec.attribute13;
        l_tif_tbl(record_number).attribute14                     :=  termnt_rec.attribute14;
        l_tif_tbl(record_number).attribute15                     :=  termnt_rec.attribute15;
        l_tif_tbl(record_number).created_by                      :=  termnt_rec.created_by;
        l_tif_tbl(record_number).creation_date                   :=  termnt_rec.creation_date;
        l_tif_tbl(record_number).last_updated_by                 :=  termnt_rec.last_updated_by;
        l_tif_tbl(record_number).last_update_date                :=  termnt_rec.last_update_date;
        l_tif_tbl(record_number).last_update_login               :=  termnt_rec.last_update_login;
        l_tif_tbl(record_number).group_number                    :=  termnt_rec.group_number;
        record_number                                            :=  record_number+1;
        END LOOP;

        tot_rec_processed         := l_tif_tbl.COUNT;
        -- validates quote_type and quote_reason and populates WHO columns
        validate_quote_type_and_reason(p_api_version    => l_api_version,
                                       p_init_msg_list  => OKC_API.G_TRUE,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data,
                                       x_return_status  => x_return_status,
                                       p_tif_tbl        => l_tif_tbl,
                                       x_tif_tbl        => lx_tif_tbl);
        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- validates contract and asset details entered, populates the remaining calls required
        validate_transaction(p_api_version    => l_api_version,
                             p_init_msg_list  => OKC_API.G_FALSE,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_return_status  => x_return_status,
                             p_tif_tbl        => l_tif_tbl,
                             p_sys_date       => l_sys_date,
                             x_tif_tbl        => lx_tif_tbl);
        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- updates the values in database and gets records with status='WORKING'
        change_status(p_api_version    => l_api_version,
                      p_init_msg_list  => OKC_API.G_FALSE,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      x_return_status  => x_return_status,
                      p_tif_tbl        => l_tif_tbl,
                      x_tif_tbl        => lx_tif_tbl);

        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- selects the party information and populates WHO columns in party table
        select_party_info(p_api_version    => l_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_tip_tbl        => l_tip_tbl,
                          x_tip_tbl        => lx_tip_tbl,
                          p_pty_status     => 'ENTERED');
        l_tip_tbl.DELETE;
        l_tip_tbl := lx_tip_tbl;
        lx_tip_tbl.DELETE;
        -- validates party information
        validate_party(p_api_version    => l_api_version,
                       p_init_msg_list  => OKC_API.G_FALSE,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_return_status  => x_return_status,
                       p_tif_tbl        => l_tif_tbl,
                       x_tif_tbl        => lx_tif_tbl,
                       p_tip_tbl        => l_tip_tbl,
                       x_tip_tbl        => lx_tip_tbl);
        l_tip_tbl.DELETE;
        l_tip_tbl := lx_tip_tbl;
        lx_tip_tbl.DELETE;

        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- updates values in database and gets records with status='WORKING'
        select_party_info(p_api_version    => l_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_tip_tbl        => l_tip_tbl,
                          x_tip_tbl        => lx_tip_tbl,
                          p_pty_status     => 'WORKING');
        l_tip_tbl.DELETE;
        l_tip_tbl := lx_tip_tbl;
        lx_tip_tbl.DELETE;
        -- populates the fields required for quote and creates quote for entries in party table
        populate_party_for_quote(p_api_version    => l_api_version,
                                 p_init_msg_list  => OKC_API.G_FALSE,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 x_return_status  => x_return_status,
                                 p_tip_tbl        => l_tip_tbl,
                                 p_tif_tbl        => l_tif_tbl,
                                 x_tif_tbl        => lx_tif_tbl,
                                 x_group_number   => l_group_number);
        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- updates the values to database and removes the duplicates while grouping
        remove_duplicates(p_api_version    => l_api_version,
                          p_init_msg_list  => OKC_API.G_FALSE,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          x_return_status  => x_return_status,
                          p_tif_tbl        => l_tif_tbl,
                          x_tif_tbl        => lx_tif_tbl);

        l_tif_tbl.DELETE;
        l_tif_tbl := lx_tif_tbl;
        lx_tif_tbl.DELETE;
        -- creates groups and calls create_quote
        populate_quote(p_api_version    => l_api_version,
                       p_init_msg_list  => OKC_API.G_FALSE,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_return_status  => x_return_status,
                       p_tif_tbl        => l_tif_tbl,
                       x_tif_tbl        => lx_tif_tbl,
                       p_group_number   => l_group_number);

        OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
        log_messages(log_msg_flag             => 'Y',
                     p_quote_number           => tot_rec_processed,
                     msg_tbl                  => l_msg_tbl );
        log_messages(log_msg_flag             => 'O',
                     p_quote_number           => tot_rec_processed,
                     msg_tbl                  => l_msg_tbl );
EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
          x_return_status := OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                       G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_ERROR',
                                                       x_msg_count,
                                                       x_msg_data,
                                                      '_PVT');
        -- unexpected error
        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          x_return_status :=OKC_API.HANDLE_EXCEPTIONS(l_api_name,
                                                      G_PKG_NAME,
                                                      'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                      x_msg_count,
                                                      x_msg_data,
                                                      '_PVT');
         WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => g_unexpected_error,
                              p_token1        => g_sqlcode_token,
                              p_token1_value  => sqlcode,
                              p_token2        => g_sqlerrm_token,
                              p_token2_value  => sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           l_msg_tbl(0).msg_text      := 'termination_interface:ended with unexpected error sqlcode: '||sqlcode||' sqlerrm: '||sqlerrm;
           log_messages(log_msg_flag             => 'Y',
                        p_quote_number           => tot_rec_processed,
                        msg_tbl                  => l_msg_tbl );
           log_messages(log_msg_flag             => 'O',
                        p_quote_number           => tot_rec_processed,
                        msg_tbl                  => l_msg_tbl );

    END termination_interface;
END OKL_AM_TERMNT_INTERFACE_PVT;

/
