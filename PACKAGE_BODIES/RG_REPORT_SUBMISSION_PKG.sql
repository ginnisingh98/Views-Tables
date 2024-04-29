--------------------------------------------------------
--  DDL for Package Body RG_REPORT_SUBMISSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_SUBMISSION_PKG" as
/* $Header: rgursubb.pls 120.20.12010000.2 2008/11/10 10:43:42 kmotepal ship $ */

    --
    -- Name
    --    submit_report_set()
    -- Purpose
    --    Submit the whole report set
    -- ARGUMENTS
    --    1. concurrent request id
    --    2. application short name
    --    3. data access set id
    --    4. report set period
    --    5. accounting date
    --    6. default ledger short name
    --    7. unit of measure id
    --    8. report set id
    --    9. page length
    --   10. report set request id
    -- CALLS
    --    submit_report: submit a report in the report set
    -- CALLED BY
    --    form RGXGRRST
    --

    FUNCTION submit_report_set(
                       conc_req_ids              IN OUT NOCOPY VARCHAR2,
                       appl_short_name           IN VARCHAR2,
                       data_access_set_id        IN NUMBER,
                       set_period_name           IN VARCHAR2,
                       accounting_date           IN DATE,
                       default_ledger_short_name IN VARCHAR2,
                       unit_of_m_id              IN VARCHAR2,
                       report_set_id             IN NUMBER,
                       page_len                  IN NUMBER,
                       report_set_request_id     IN NUMBER)
        RETURN          BOOLEAN
    IS
        first_conc_req    BOOLEAN := TRUE;
        temp_conc_req_id  NUMBER  := 0;
        CURSOR c (set_id NUMBER) IS
                SELECT REPORT_ID,REPORT_REQUEST_ID
                FROM RG_REPORT_REQUESTS
                WHERE REPORT_SET_ID = set_id
                ORDER BY sequence ASC;
    BEGIN

        FOR report IN c(report_set_id) LOOP
          IF (NOT submit_report(temp_conc_req_id,
                                set_period_name,
                                accounting_date,
                                default_ledger_short_name,
                                unit_of_m_id,
                                data_access_set_id,
                                appl_short_name,
                                report.report_id,
                                page_len,
                                report.report_request_id,
                                report_set_request_id)) THEN
             RETURN FALSE;
          ELSE
            IF (first_conc_req = TRUE) THEN
              conc_req_ids := TO_CHAR(temp_conc_req_id);
              first_conc_req := FALSE;
            ELSE
              IF (LENGTH(conc_req_ids) + LENGTH(TO_CHAR(temp_conc_req_id))
                 <= 1998) THEN
                conc_req_ids := conc_req_ids || ', ' ||
                                TO_CHAR(temp_conc_req_id);
              END IF;
            END IF;
          END IF;
        END LOOP;

        return(TRUE);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.set_name('RG','RGXGRRST_REPORTSET_NO_REPORT');
            app_exception.raise_exception;

            RETURN(TRUE);

    END submit_report_set;

    -- Name
    --     submit_report
    -- Purpose
    --     Submit a report in the report set
    -- Arguments
    --          1. concurrent request id
    --          2. report set period name
    --          3. accounting date
    --          4. default ledger short name
    --          5. unit of measure id
    --          6. data access set id
    --          7. appl_short_name
    --          8. report id
    --          9. page length
    --         10. report request id
    --         11. report set request id
    -- Calls
    --    FND_REQUEST.SUBMIT_REQUEST
    -- Call By
    --    submit_report_set
    --

   FUNCTION  submit_report(conc_req_id                  IN OUT NOCOPY NUMBER,
                           set_period_name              IN VARCHAR2,
                           accounting_date              IN DATE,
                           default_ledger_short_name    IN VARCHAR2,
                           unit_of_m_id                 IN VARCHAR2,
                           data_access_set_id           IN NUMBER,
                           appl_short_name              IN VARCHAR2,
                           rep_id                       IN NUMBER,
                           page_len                     IN NUMBER,
                           rep_request_id               IN NUMBER,
                           report_set_request_id        IN NUMBER)
        RETURN               BOOLEAN
   IS
        TYPE RepTyp IS RECORD
               (row_set_id              NUMBER(15),
                column_set_id           NUMBER(15),
                unit_of_measure_id      VARCHAR2(30),
                content_set_id          NUMBER(15),
                row_order_id            NUMBER(15),
                rounding_option         VARCHAR2(1),
                parameter_set_id        NUMBER(15),
                minimum_display_level   NUMBER(15),
                report_display_set_id   NUMBER(15),
                output_option           VARCHAR2(1),
                report_title            VARCHAR2(240),
                segment_override        VARCHAR2(800),
                override_alc_ledger_currency VARCHAR2(30));

        report_rec           RepTyp;
        rep_run_type         rg_report_content_sets.report_run_type%TYPE;
        cur_currency         rg_reports.unit_of_measure_id%TYPE;

        report_sequence      NUMBER;

        -- ALC processing
        seg_override         VARCHAR2(800);
        ledger_id            NUMBER;
        alc_ledger_currency  VARCHAR2(30);
        translated_flag      VARCHAR2(1);

        -- Additional parameters
        coa_id               NUMBER := 101;
        adhoc_prefix         VARCHAR2(20);
        industry             VARCHAR2(1);
        flex_code            VARCHAR2(5);
        subrequest_id        NUMBER := -998;
        appl_deflt_name      VARCHAR2(6);

        nlslang              VARCHAR2(30);
        nlsterr              VARCHAR2(30);
        nlsnumeric           VARCHAR2(2);

   BEGIN

         /*Code fix for 6846465 starts here */
         nlslang := fnd_profile.value('ICX_LANGUAGE');
         nlsterr := fnd_profile.value('ICX_TERRITORY');
         nlsnumeric := fnd_profile.value('ICX_NUMERIC_CHARACTERS');
         IF (NOT FND_REQUEST.SET_OPTIONS('NO', 'NO', nlslang, nlsterr, NULL, nlsnumeric))
         THEN
             null;
         END IF;

         /*Code fix for 6846465 ends here */

        SELECT  row_set_id,
                column_set_id,
                unit_of_measure_id,
                content_set_id,
                row_order_id,
                rounding_option,
                parameter_set_id,
                minimum_display_level,
                report_display_set_id,
                output_option,
                name,
                segment_override,
                override_alc_ledger_currency
        INTO    report_rec
        FROM    RG_REPORTS
        WHERE   REPORT_ID = rep_id;

        adhoc_prefix := 'FSG-ADHOC-';
        industry := 'C';
        flex_code := 'GLLE';
        appl_deflt_name := 'SQLGL';

        -- Override the currency of the request by the currency of
        -- the report if it was assigned in define report form.
        --
        IF (report_rec.unit_of_measure_id IS NOT NULL) THEN
           cur_currency := report_rec.unit_of_measure_id;
        ELSE
           cur_currency := unit_of_m_id;
        END IF;

        seg_override := rg_reports_pkg.find_report_segment_override(rep_id);

        --
        -- If content set is used by this report then
        -- check the report run method.
        -- Notes: this PL/SQL  is used to submit the requests
        -- which have not been query up by the form, therefore
        -- we don't need to worry about the runtime override of
        -- these requests. i.e. no runtime override in these requests
        --
        IF (report_rec.content_set_id <> -1) THEN
           SELECT report_run_type
           INTO   rep_run_type
           FROM   rg_report_content_sets
           WHERE  content_set_id = report_rec.content_set_id;

           IF (rep_run_type = 'P') THEN
             conc_req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                'RGSSRQ',
                                report_rec.report_title,
                                '',
                                FALSE,
                                TO_CHAR(data_access_set_id),
                                TO_CHAR(coa_id),
                                adhoc_prefix,
                                industry,
                                flex_code,
                                default_ledger_short_name,
                                TO_CHAR(rep_id),
                                TO_CHAR(report_rec.row_set_id),
                                TO_CHAR(report_rec.column_set_id),
                                set_period_name,
                                cur_currency,
                                report_rec.rounding_option,
                                seg_override,
                                TO_CHAR(report_rec.content_set_id),
                                TO_CHAR(report_rec.row_order_id),
                                TO_CHAR(report_rec.report_display_set_id),
                                report_rec.output_option,
                                'N',
                                TO_CHAR(report_rec.minimum_display_level),
                                TO_CHAR(accounting_date, 'YYYY/MM/DD'),
                                TO_CHAR(report_rec.parameter_set_id),
                                TO_CHAR(page_len),
                                appl_short_name,
                                chr(0),
                                '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', '',
                                '', '', '', '', '', '', '', '', '', ''
                                );
             IF (report_rec.output_option = 'Y') THEN
               UPDATE   FND_CONCURRENT_REQUESTS
               SET
                 OUTPUT_FILE_TYPE = 'XML'
               WHERE
                 REQUEST_ID = conc_req_id;
             END IF;
           ELSE
             conc_req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                 'RGRARG',
                                 report_rec.report_title,
                                 '',
                                 FALSE,
                                TO_CHAR(data_access_set_id),
                                TO_CHAR(coa_id),
                                adhoc_prefix,
                                industry,
                                flex_code,
                                default_ledger_short_name,
                                TO_CHAR(rep_id),
                                TO_CHAR(report_rec.row_set_id),
                                TO_CHAR(report_rec.column_set_id),
                                set_period_name,
                                cur_currency,
                                report_rec.rounding_option,
                                seg_override,
                                TO_CHAR(report_rec.content_set_id),
                                TO_CHAR(report_rec.row_order_id),
                                TO_CHAR(report_rec.report_display_set_id),
                                report_rec.output_option,
                                'N',
                                TO_CHAR(report_rec.minimum_display_level),
                                TO_CHAR(accounting_date, 'YYYY/MM/DD'),
                                TO_CHAR(report_rec.parameter_set_id),
                                TO_CHAR(page_len),
                                TO_CHAR(subrequest_id),
                                 appl_short_name,
                                 chr(0),
                                 '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', ''
                                 );
             IF (report_rec.output_option = 'Y') THEN
               UPDATE   FND_CONCURRENT_REQUESTS
               SET
                 OUTPUT_FILE_TYPE = 'XML'
               WHERE
                 REQUEST_ID = conc_req_id;
             END IF;
          END IF;
        ELSE
          conc_req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                 'RGRARG',
                                 report_rec.report_title,
                                 '',
                                 FALSE,
                                TO_CHAR(data_access_set_id),
                                TO_CHAR(coa_id),
                                adhoc_prefix,
                                industry,
                                flex_code,
                                default_ledger_short_name,
                                TO_CHAR(rep_id),
                                TO_CHAR(report_rec.row_set_id),
                                TO_CHAR(report_rec.column_set_id),
                                set_period_name,
                                cur_currency,
                                report_rec.rounding_option,
                                seg_override,
                                TO_CHAR(report_rec.content_set_id),
                                TO_CHAR(report_rec.row_order_id),
                                TO_CHAR(report_rec.report_display_set_id),
                                report_rec.output_option,
                                'N',
                                TO_CHAR(report_rec.minimum_display_level),
                                TO_CHAR(accounting_date, 'YYYY/MM/DD'),
                                TO_CHAR(report_rec.parameter_set_id),
                                TO_CHAR(page_len),
                                TO_CHAR(subrequest_id),
                                 appl_short_name,
                                 chr(0),
                                 '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', ''
                                 );
             IF (report_rec.output_option = 'Y') THEN
               UPDATE   FND_CONCURRENT_REQUESTS
               SET
                 OUTPUT_FILE_TYPE = 'XML'
               WHERE
                 REQUEST_ID = conc_req_id;
             END IF;
        END IF;

        --
        -- return false if failed
        --
        IF (conc_req_id=0) THEN
           RETURN FALSE;
        END IF;

        --
        -- Else update the request in the database
        --
        GL_LEDGER_UTILS_PKG.Find_Ledger(default_ledger_short_name,
                                        ledger_id,
                                        alc_ledger_currency,
                                        translated_flag);
        IF (translated_flag = 'N') THEN
          alc_ledger_currency := NULL;
        END IF;

        UPDATE  RG_REPORT_REQUESTS
        SET
                CONCURRENT_REQUEST_ID   = conc_req_id,
                PERIOD_NAME             = set_period_name,
                ACCOUNTING_DATE         = accounting_date,
                LEDGER_ID               = ledger_id,
                ALC_LEDGER_CURRENCY     = alc_ledger_currency,
                UNIT_OF_MEASURE_ID      = unit_of_m_id,
                ROUNDING_OPTION         = report_rec.rounding_option,
                SEGMENT_OVERRIDE        = report_rec.segment_override,
                OVERRIDE_ALC_LEDGER_CURRENCY
                                    = report_rec.override_alc_ledger_currency,
                CONTENT_SET_ID          = report_rec.content_set_id,
                ROW_ORDER_ID            = report_rec.row_order_id,
                EXCEPTIONS_FLAG         = 'N',
                REPORT_DISPLAY_SET_ID   = report_rec.report_display_set_id,
                OUTPUT_OPTION           = report_rec.output_option
        WHERE   REPORT_REQUEST_ID       = rep_request_id;

        --
        -- Report set request enhancement
        --
        IF (report_set_request_id IS NOT NULL) THEN
          SELECT SEQUENCE
          INTO   report_sequence
          FROM   RG_REPORT_REQUESTS
          WHERE  REPORT_REQUEST_ID = rep_request_id;

          RG_REPORT_SET_REQUESTS_PKG.insert_report_set_req_detail(
                 report_set_request_id,
                 report_sequence,
                 rep_id,
                 conc_req_id);
        END IF;

        return TRUE;
   END submit_report;

   FUNCTION  submit_request
               (X_APPL_SHORT_NAME               IN      VARCHAR2,
                X_DATA_ACCESS_SET_ID            IN      NUMBER,
                X_CONCURRENT_REQUEST_ID         OUT NOCOPY NUMBER,
                X_PROGRAM                       OUT NOCOPY VARCHAR2,
                X_COA_ID                        IN      NUMBER,
                X_ADHOC_PREFIX                  IN      VARCHAR2,
                X_INDUSTRY                      IN      VARCHAR2,
                X_FLEX_CODE                     IN      VARCHAR2,
                X_DEFAULT_LEDGER_SHORT_NAME     IN      VARCHAR2,
                X_REPORT_ID                     IN      NUMBER,
                X_ROW_SET_ID                    IN      NUMBER,
                X_COLUMN_SET_ID                 IN      NUMBER,
                X_PERIOD_NAME                   IN      VARCHAR2,
                X_UNIT_OF_MEASURE_ID            IN      VARCHAR2,
                X_ROUNDING_OPTION               IN      VARCHAR2,
                X_SEGMENT_OVERRIDE              IN      VARCHAR2,
                X_CONTENT_SET_ID                IN      NUMBER,
                X_ROW_ORDER_ID                  IN      NUMBER,
                X_REPORT_DISPLAY_SET_ID         IN      NUMBER,
                X_OUTPUT_OPTION                 IN      VARCHAR2,
                X_EXCEPTIONS_FLAG               IN      VARCHAR2,
                X_MINIMUM_DISPLAY_LEVEL         IN      NUMBER,
                X_ACCOUNTING_DATE               IN      DATE,
                X_PARAMETER_SET_ID              IN      NUMBER,
                X_PAGE_LENGTH                   IN      NUMBER,
                X_SUBREQUEST_ID                 IN      NUMBER,
                X_APPL_DEFLT_NAME               IN      VARCHAR2)
             RETURN     BOOLEAN
   IS
     TYPE RepTyp IS RECORD
               (row_set_id              NUMBER(15),
                column_set_id           NUMBER(15),
                unit_of_measure_id      VARCHAR2(30),
                content_set_id          NUMBER(15),
                row_order_id            NUMBER(15),
                rounding_option         VARCHAR2(1),
                parameter_set_id        NUMBER(15),
                minimum_display_level   NUMBER(15),
                report_display_set_id   NUMBER(15),
                output_option           VARCHAR2(1),
                report_title            VARCHAR2(240),
                segment_override        VARCHAR2(800));

     report_rec         RepTyp;

     req_id             NUMBER;
     rep_run_type       rg_report_content_sets.report_run_type%TYPE;

        nlslang              VARCHAR2(30);
        nlsterr              VARCHAR2(30);
        nlsnumeric           VARCHAR2(2);
   BEGIN

         /*Code fix for 6846465 starts here */
         nlslang := fnd_profile.value('ICX_LANGUAGE');
         nlsterr := fnd_profile.value('ICX_TERRITORY');
         nlsnumeric := fnd_profile.value('ICX_NUMERIC_CHARACTERS');
         IF (NOT FND_REQUEST.SET_OPTIONS('NO', 'NO', nlslang, nlsterr, NULL, nlsnumeric))
         THEN
             null;
         END IF;

         /*Code fix for 6846465 ends here */

      SELECT    row_set_id,
                column_set_id,
                unit_of_measure_id,
                content_set_id,
                row_order_id,
                rounding_option,
                parameter_set_id,
                minimum_display_level,
                report_display_set_id,
                output_option,
                name,
                segment_override
      INTO    report_rec
      FROM    RG_REPORTS
      WHERE   REPORT_ID = X_REPORT_ID;

      --
      -- If content set is used by this report then
      -- check the report run method.
      --
      IF (X_content_set_id IS NOT NULL) THEN
         SELECT report_run_type
         INTO   rep_run_type
         FROM   rg_report_content_sets
         WHERE  content_set_id = X_content_set_id;
      ELSE
         rep_run_type := 'S';
      END IF;

      IF (rep_run_type = 'P') THEN
         X_PROGRAM := 'RGSSRQ';
         req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                'RGSSRQ',
                                report_rec.report_title,
                                '',
                                FALSE,
                                TO_CHAR(X_data_access_set_id),
                                TO_CHAR(X_COA_ID),
                                X_ADHOC_PREFIX,
                                X_INDUSTRY,
                                X_FLEX_CODE,
                                X_default_ledger_short_name,
                                TO_CHAR(X_report_id),
                                TO_CHAR(X_row_set_id),
                                TO_CHAR(X_column_set_id),
                                X_period_name,
                                X_unit_of_measure_id,
                                X_rounding_option,
                                X_segment_override,
                                TO_CHAR(X_content_set_id),
                                TO_CHAR(X_row_order_id),
                                TO_CHAR(X_report_display_set_id),
                                X_output_option,
                                X_exceptions_flag,
                                TO_CHAR(X_minimum_display_level),
                                TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
                                TO_CHAR(X_parameter_set_id),
                                TO_CHAR(X_page_length),
                                X_appl_deflt_name,
                                chr(0),
                                 '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', ''
                                 );
         IF (X_output_option = 'Y') THEN
            UPDATE      FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
         END IF;
      ELSE
          X_PROGRAM := 'RGRARG';
          req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                   'RGRARG',
                                   report_rec.report_title,
                                   '',
                                   FALSE,
                                   TO_CHAR(X_data_access_set_id),
                                   TO_CHAR(X_COA_ID),
                                   X_ADHOC_PREFIX,
                                   X_INDUSTRY,
                                   X_FLEX_CODE,
                                   X_default_ledger_short_name,
                                   TO_CHAR(X_report_id),
                                   TO_CHAR(X_row_set_id),
                                   TO_CHAR(X_column_set_id),
                                   X_period_name,
                                   X_unit_of_measure_id,
                                   X_rounding_option,
                                   X_segment_override,
                                   TO_CHAR(X_content_set_id),
                                   TO_CHAR(X_row_order_id),
                                   TO_CHAR(X_report_display_set_id),
                                   X_output_option,
                                   X_exceptions_flag,
                                   TO_CHAR(X_minimum_display_level),
                                   TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
                                   TO_CHAR(X_parameter_set_id),
                                   TO_CHAR(X_page_length),
                                   TO_CHAR(X_SUBREQUEST_ID),
                                   X_appl_deflt_name,
                                   chr(0),
                                   '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', ''
                                   );
         IF (X_output_option = 'Y') THEN
            UPDATE      FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
         END IF;
      END IF;

      IF (req_id = 0) THEN
         RETURN FALSE;
      ELSE
         X_concurrent_request_id:= req_id;
         return TRUE;
      END IF;
   END submit_request;

   FUNCTION  submit_request_addparam
               (X_APPL_SHORT_NAME       IN      VARCHAR2,
                X_DATA_ACCESS_SET_ID            IN      NUMBER,
                X_CONCURRENT_REQUEST_ID         OUT NOCOPY NUMBER,
                X_PROGRAM                       OUT NOCOPY VARCHAR2,
                X_COA_ID                        IN      NUMBER,
                X_ADHOC_PREFIX                  IN      VARCHAR2,
                X_INDUSTRY                      IN      VARCHAR2,
                X_FLEX_CODE                     IN      VARCHAR2,
                X_DEFAULT_LEDGER_SHORT_NAME     IN      VARCHAR2,
                X_REPORT_ID                     IN      NUMBER,
                X_ROW_SET_ID                    IN      NUMBER,
                X_COLUMN_SET_ID                 IN      NUMBER,
                X_PERIOD_NAME                   IN      VARCHAR2,
                X_UNIT_OF_MEASURE_ID            IN      VARCHAR2,
                X_ROUNDING_OPTION               IN      VARCHAR2,
                X_SEGMENT_OVERRIDE              IN      VARCHAR2,
                X_CONTENT_SET_ID                IN      NUMBER,
                X_ROW_ORDER_ID                  IN      NUMBER,
                X_REPORT_DISPLAY_SET_ID         IN      NUMBER,
                X_OUTPUT_OPTION                 IN      VARCHAR2,
                X_EXCEPTIONS_FLAG               IN      VARCHAR2,
                X_MINIMUM_DISPLAY_LEVEL         IN      NUMBER,
                X_ACCOUNTING_DATE               IN      DATE,
                X_PARAMETER_SET_ID              IN      NUMBER,
                X_PAGE_LENGTH                   IN      NUMBER,
                X_SUBREQUEST_ID                 IN      NUMBER,
                X_APPL_DEFLT_NAME               IN      VARCHAR2,
                X_GBL_PARAM01           IN      VARCHAR2,
                X_GBL_PARAM02           IN      VARCHAR2,
                X_GBL_PARAM03           IN      VARCHAR2,
                X_GBL_PARAM04           IN      VARCHAR2,
                X_GBL_PARAM05           IN      VARCHAR2,
                X_GBL_PARAM06           IN      VARCHAR2,
                X_GBL_PARAM07           IN      VARCHAR2,
                X_GBL_PARAM08           IN      VARCHAR2,
                X_GBL_PARAM09           IN      VARCHAR2,
                X_GBL_PARAM10           IN      VARCHAR2,
                X_CST_PARAM01           IN      VARCHAR2,
                X_CST_PARAM02           IN      VARCHAR2,
                X_CST_PARAM03           IN      VARCHAR2,
                X_CST_PARAM04           IN      VARCHAR2,
                X_CST_PARAM05           IN      VARCHAR2,
                X_CST_PARAM06           IN      VARCHAR2,
                X_CST_PARAM07           IN      VARCHAR2,
                X_CST_PARAM08           IN      VARCHAR2,
                X_CST_PARAM09           IN      VARCHAR2,
                X_CST_PARAM10           IN      VARCHAR2)
             RETURN     BOOLEAN
   IS
        TYPE RepTyp IS RECORD
               (row_set_id              NUMBER(15),
                column_set_id           NUMBER(15),
                unit_of_measure_id      VARCHAR2(30),
                content_set_id          NUMBER(15),
                row_order_id            NUMBER(15),
                rounding_option         VARCHAR2(1),
                parameter_set_id        NUMBER(15),
                minimum_display_level   NUMBER(15),
                report_display_set_id   NUMBER(15),
                output_option           VARCHAR2(1),
                report_title            VARCHAR2(240),
                segment_override        VARCHAR2(800));

        report_rec      RepTyp;
        req_id          NUMBER;
        rep_run_type    rg_report_content_sets.report_run_type%TYPE;
   BEGIN

        SELECT  row_set_id,
                column_set_id,
                unit_of_measure_id,
                content_set_id,
                row_order_id,
                rounding_option,
                parameter_set_id,
                minimum_display_level,
                report_display_set_id,
                output_option,
                name,
                segment_override
        INTO    report_rec
        FROM    RG_REPORTS
        WHERE   REPORT_ID = X_REPORT_ID;

      --
      -- If content set is used by this report then
      -- check the report run method.
      --
      IF (X_content_set_id IS NOT NULL) THEN
         SELECT report_run_type
         INTO   rep_run_type
         FROM   rg_report_content_sets
         WHERE  content_set_id = X_content_set_id;
      ELSE
         rep_run_type := 'S';
      END IF;

      IF (rep_run_type = 'P') THEN
         X_PROGRAM := 'RGSSRQ';
         req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                'RGSSRQ',
                                report_rec.report_title,
                                '',
                                FALSE,
                                TO_CHAR(X_data_access_set_id),
                                TO_CHAR(X_COA_ID),
                                X_ADHOC_PREFIX,
                                X_INDUSTRY,
                                X_FLEX_CODE,
                                X_default_ledger_short_name,
                                TO_CHAR(X_report_id),
                                TO_CHAR(X_row_set_id),
                                TO_CHAR(X_column_set_id),
                                X_period_name,
                                X_unit_of_measure_id,
                                X_rounding_option,
                                X_segment_override,
                                TO_CHAR(X_content_set_id),
                                TO_CHAR(X_row_order_id),
                                TO_CHAR(X_report_display_set_id),
                                X_output_option,
                                X_exceptions_flag,
                                TO_CHAR(X_minimum_display_level),
                                TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
                                TO_CHAR(X_parameter_set_id),
                                TO_CHAR(X_page_length),
                                X_appl_deflt_name,
                                X_GBL_PARAM01,
                                X_GBL_PARAM02,
                                X_GBL_PARAM03,
                                X_GBL_PARAM04,
                                X_GBL_PARAM05,
                                X_GBL_PARAM06,
                                X_GBL_PARAM07,
                                X_GBL_PARAM08,
                                X_GBL_PARAM09,
                                X_GBL_PARAM10,
                                X_CST_PARAM01,
                                X_CST_PARAM02,
                                X_CST_PARAM03,
                                X_CST_PARAM04,
                                X_CST_PARAM05,
                                X_CST_PARAM06,
                                X_CST_PARAM07,
                                X_CST_PARAM08,
                                X_CST_PARAM09,
                                X_CST_PARAM10,
                                 chr(0),
                                 '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', ''
                                 );
         IF (X_output_option = 'Y') THEN
            UPDATE      FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
          END IF;
      ELSE
         X_PROGRAM := 'RGRARG';
         req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
                                   'RGRARG',
                                   report_rec.report_title,
                                   '',
                                   FALSE,
                                   TO_CHAR(X_data_access_set_id),
                                   TO_CHAR(X_COA_ID),
                                   X_ADHOC_PREFIX,
                                   X_INDUSTRY,
                                   X_FLEX_CODE,
                                   X_default_ledger_short_name,
                                   TO_CHAR(X_report_id),
                                   TO_CHAR(X_row_set_id),
                                   TO_CHAR(X_column_set_id),
                                   X_period_name,
                                   X_unit_of_measure_id,
                                   X_rounding_option,
                                   X_segment_override,
                                   TO_CHAR(X_content_set_id),
                                   TO_CHAR(X_row_order_id),
                                   TO_CHAR(X_report_display_set_id),
                                   X_output_option,
                                   X_exceptions_flag,
                                   TO_CHAR(X_minimum_display_level),
                                   TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
                                   TO_CHAR(X_parameter_set_id),
                                   TO_CHAR(X_page_length),
                                   TO_CHAR(X_SUBREQUEST_ID),
                                   X_appl_deflt_name,
                                   X_GBL_PARAM01,
                                   X_GBL_PARAM02,
                                   X_GBL_PARAM03,
                                   X_GBL_PARAM04,
                                   X_GBL_PARAM05,
                                   X_GBL_PARAM06,
                                   X_GBL_PARAM07,
                                   X_GBL_PARAM08,
                                   X_GBL_PARAM09,
                                   X_GBL_PARAM10,
                                   X_CST_PARAM01,
                                   X_CST_PARAM02,
                                   X_CST_PARAM03,
                                   X_CST_PARAM04,
                                   X_CST_PARAM05,
                                   X_CST_PARAM06,
                                   X_CST_PARAM07,
                                   X_CST_PARAM08,
                                   X_CST_PARAM09,
                                   X_CST_PARAM10,
                                   chr(0),
                                   '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', ''
                                   );
         IF (X_output_option = 'Y') THEN
            UPDATE      FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
          END IF;
      END IF;

      IF (req_id=0) THEN
         RETURN FALSE;
      ELSE
         X_concurrent_request_id:= req_id;
        return TRUE;
      END IF;
   END submit_request_addparam;

   FUNCTION  submit_xml_request(
                X_APPL_SHORT_NAME IN    VARCHAR2,
                X_IN_CONC_REQ_ID  IN    NUMBER,
                X_CONCURRENT_REQUEST_ID OUT NOCOPY NUMBER,
                X_PROGRAM               OUT NOCOPY VARCHAR2,
                X_TEMPLATE_CODE         IN      VARCHAR2,
                X_APPLICATION_ID        IN      NUMBER) RETURN BOOLEAN
                IS
        l_return BOOLEAN;
        req_id  NUMBER;
        l_in_conc_req_id VARCHAR2(30);
        l_application_id VARCHAR2(10);
        l_locale         VARCHAR2(10);
        l_template_code  VARCHAR2(80);
   BEGIN
      --
      SELECT    template_code
      INTO    l_template_code
      FROM    XDO_TEMPLATES_VL
      WHERE   description = X_TEMPLATE_CODE;
      --
      req_id := 0;
      l_in_conc_req_id := LTRIM(RTRIM(TO_CHAR(X_IN_CONC_REQ_ID)));
      l_application_id := LTRIM(RTRIM(TO_CHAR(X_APPLICATION_ID)));
      --
      l_locale := '';
      --
      X_PROGRAM := 'XDOREPPB';
      --
      req_id := FND_REQUEST.SUBMIT_REQUEST(X_APPL_SHORT_NAME,'XDOREPPB',
                'XML Publisher',NULL,FALSE,
                l_in_conc_req_id,
                l_template_code,l_application_id,l_locale,'N','RTF','PDF',
                CHR(0),'','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','');
       --
       X_CONCURRENT_REQUEST_ID := req_id;
       IF (req_id = 0) THEN
          l_return := FALSE;
          RETURN l_return;
       ELSE
          l_return := TRUE;
          RETURN l_return;
       END IF;
   END submit_xml_request;

END rg_report_submission_pkg;

/
