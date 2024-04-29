--------------------------------------------------------
--  DDL for Package Body JG_GLOBE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_GLOBE_UTIL_PKG" AS
/* $Header: jggutilb.pls 120.2.12010000.2 2009/06/17 10:28:09 vspuli noship $ */

   l_line           VARCHAR2 (1999);
   pg_debug_level   NUMBER;

   -- A procedure to process Globe events from ICX
   -- A procedure to process Globe events from ICX
   FUNCTION process_icx_line_globe_event (
      p_org_id              IN   NUMBER,
      p_item_id             IN   NUMBER,
      p_deliver_to_org_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_txn_reason_code   VARCHAR2 (80) := ' ';
   BEGIN
      DEBUG ('Entered process_icx_line_globe_event');
      DEBUG (p_org_id);
      DEBUG (p_item_id);
      DEBUG (p_deliver_to_org_id);
      DEBUG (l_txn_reason_code);

      IF jg_zz_shared_pkg.get_product (p_org_id, NULL) = 'JL'
      THEN
         DEBUG ('Calling JL hook');

         SELECT jl_globe_util_pkg.populate_icx_trx_reason_code
                                                          (p_org_id,
                                                           p_item_id,
                                                           p_deliver_to_org_id
                                                          )
           INTO l_txn_reason_code
           FROM DUAL;

         DEBUG ('Returned from JL hook' || l_txn_reason_code);
      ELSE
         NULL;
      END IF;

      RETURN (NVL (l_txn_reason_code, ''));
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG ('Error Code' || SQLCODE);
         DEBUG ('Error Message' || SQLERRM);
         RETURN ' ';
   END process_icx_line_globe_event;

-- A procedure to process Globe events from PO
   PROCEDURE process_po_globe_event (
      p_document_type   IN   VARCHAR2,
      p_level_type      IN   VARCHAR2,
      p_level_id        IN   NUMBER
   )
   IS
      l_country_code              VARCHAR2 (10);
      l_org_id                    NUMBER;
      l_transaction_reason_code   VARCHAR2 (30);
   BEGIN
      SELECT org_id
        INTO l_org_id
        FROM po_lines_all
       WHERE po_line_id = p_level_id;

      DEBUG (p_document_type);
      DEBUG (p_level_type);
      DEBUG (p_level_id);
      DEBUG (l_org_id);

      IF jg_zz_shared_pkg.get_product (l_org_id, NULL) = 'JL'
      THEN
         IF     p_document_type IN ('STANDARD', 'BLANKET')
            AND p_level_type = 'LINE'
         THEN
            SELECT transaction_reason_code
              INTO l_transaction_reason_code
              FROM po_lines_all
             WHERE po_line_id = p_level_id;

            DEBUG ('Transaction Reason Code' || l_transaction_reason_code);

            -- If RFQ is created from Requistion, this defaulting is not needed,
            -- and the PO will get transaction reason that got defaulted in RFQ.
            IF l_transaction_reason_code IS NULL
            THEN
               DEBUG ('Calling JL hook');
               jl_globe_util_pkg.populate_po_trx_reason_code (p_level_id,
                                                              l_org_id
                                                             );
               DEBUG ('Returned from JL hook');
            END IF;
         END IF;
      ELSE
         NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (SQLCODE);
         DEBUG (SQLERRM);
   END process_po_globe_event;

   /* ---------------------------------------------------------------------*
    |Public Procedure                                                       |
    |      debug        Write the text message  in log file                 |
    |                   if the debug is set "Yes".                          |
    | Description       This procedure will generate the standard debug     |
    |                   information in to the log file.User can open the    |
    |                   log file <user name.log> at specified location.     |
    |                                                                       |
    | Requires                                                              |
    |      p_line       The line of debug messages that will be writen      |
    |                   in the log file.                                    |
    | Exception Raised                                                      |
    |                                                                       |
    | Known Bugs                                                            |
    |                                                                       |
    | Notes                                                                 |
    |                                                                       |
    | History                                                               |
    |                                                                       |
    *-----------------------------------------------------------------------*/
   PROCEDURE DEBUG (p_line IN VARCHAR2)
   IS
      p_module_name                 VARCHAR2 (50);
      g_log_statement_level         NUMBER;
      g_current_runtime_level       NUMBER;
      g_level_event        CONSTANT NUMBER        := fnd_log.level_event;
      g_level_exception    CONSTANT NUMBER        := fnd_log.level_exception;
      g_level_unexpected   CONSTANT NUMBER        := fnd_log.level_unexpected;
   BEGIN
      p_module_name := 'JG: Globe Util';
      g_log_statement_level := fnd_log.level_statement;
      pg_debug_level := fnd_log.level_procedure;
      g_current_runtime_level := fnd_log.g_current_runtime_level;

      IF (g_log_statement_level >= g_current_runtime_level)
      THEN
         IF LENGTHB (p_line) > 1999
         THEN
            l_line := SUBSTRB (p_line, 1, 1999);
         ELSE
            l_line := p_line;
         END IF;

         fnd_log.STRING (log_level      => g_log_statement_level,
                         module         => p_module_name,
                         MESSAGE        => l_line
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (g_level_unexpected >= g_current_runtime_level)
         THEN
            fnd_log.STRING
                  (log_level      => fnd_log.level_unexpected,
                   module         => p_module_name,
                   MESSAGE        => 'Unexpected Error When Logging Debug Messages.'
                  );
         END IF;
   END DEBUG;
END;


/
