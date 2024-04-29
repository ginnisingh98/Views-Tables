--------------------------------------------------------
--  DDL for Package Body JL_GLOBE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_GLOBE_UTIL_PKG" AS
/* $Header: jlgutilb.pls 120.0.12010000.2 2009/06/04 07:45:38 vspuli noship $ */

   l_line           VARCHAR2 (1999);
   pg_debug_level   NUMBER;

   -- procedure to retrieve transaction reason code for PO
   PROCEDURE populate_po_trx_reason_code (
      p_level_id   IN   NUMBER,
      p_org_id          NUMBER
   )
   IS
      l_inv_org_id        NUMBER;
      l_item_id           NUMBER;
      l_trx_reason_code   VARCHAR2 (80);
   BEGIN
      DEBUG ('Begin populate_trx_reason_code');

      BEGIN
         SELECT pol.item_id
           INTO l_item_id
           FROM po_lines_all pol
          WHERE pol.po_line_id = p_level_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      DEBUG ('Item Id: ' || '**' || l_item_id || '**');

      IF l_item_id IS NOT NULL
      THEN
         BEGIN
            SELECT global_attribute2
              INTO l_trx_reason_code
              FROM mtl_system_items mtl
             WHERE mtl.organization_id = (SELECT inventory_organization_id
                                            FROM financials_system_parameters
                                           WHERE org_id = p_org_id)
               AND mtl.inventory_item_id = l_item_id
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      ELSE
         BEGIN
            SELECT global_attribute1
              INTO l_trx_reason_code
              FROM po_system_parameters
             WHERE ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END IF;

      DEBUG ('Transaction Reason Code: ' || '**' || l_trx_reason_code || '**');

      BEGIN
         UPDATE po_lines_all
            SET transaction_reason_code = l_trx_reason_code
          WHERE po_line_id = p_level_id;
      END;

      DEBUG ('End  populate_trx_reason_code');
   END populate_po_trx_reason_code;

   -- function to retrieve transaction reason code for Requisitions
   FUNCTION populate_icx_trx_reason_code (
      p_org_id              IN   NUMBER,
      p_item_id             IN   NUMBER,
      p_deliver_to_org_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_txn_reason_code       VARCHAR2 (80) := ' ';
      l_country_code          VARCHAR2 (10);
      l_org_id                NUMBER;
      l_trx_reason_def_rule   VARCHAR2 (80);
      l_def_from_org_id       NUMBER;
   BEGIN
      DEBUG ('Entered populate_icx_trx_reason_code');
      DEBUG (p_org_id);
      DEBUG (p_item_id);
      DEBUG (p_deliver_to_org_id);
      DEBUG (l_txn_reason_code);

      --
      -- get transaction reason code from mtl system items if
      -- item is known.
      -- Determine which organization to use from po system parameters
      -- and then fetch transaction reason accordingly.
      --
      IF p_item_id IS NOT NULL
      THEN
         SELECT global_attribute3
           INTO l_trx_reason_def_rule
           FROM po_system_parameters_all
          WHERE org_id = p_org_id;

         IF NVL (l_trx_reason_def_rule, 'MASTER INVENTORY ORGANIZATION') =
                                                      'INVENTORY ORGANIZATION'
         THEN
            l_def_from_org_id := p_deliver_to_org_id;

            SELECT global_attribute2
              INTO l_txn_reason_code
              FROM mtl_system_items mtl
             WHERE mtl.organization_id = l_def_from_org_id
               AND mtl.inventory_item_id = p_item_id
               AND ROWNUM = 1;

            --
            -- try to get trx reason code based on
            -- validation organization id
            --
            IF l_txn_reason_code IS NULL
            THEN
               SELECT inventory_organization_id
                 INTO l_def_from_org_id
                 FROM financials_system_parameters
                WHERE org_id = p_org_id;

               SELECT global_attribute2
                 INTO l_txn_reason_code
                 FROM mtl_system_items mtl
                WHERE mtl.organization_id = l_def_from_org_id
                  AND mtl.inventory_item_id = p_item_id
                  AND ROWNUM = 1;

               IF l_txn_reason_code IS NOT NULL
               THEN
                  --
                  -- return if trx reason code is found at validation organization id
                  --
                  RETURN l_txn_reason_code;
               END IF;
            END IF;
         ELSIF NVL (l_trx_reason_def_rule, 'MASTER INVENTORY ORGANIZATION') =
                                               'MASTER INVENTORY ORGANIZATION'
         THEN
            SELECT inventory_organization_id
              INTO l_def_from_org_id
              FROM financials_system_parameters
             WHERE org_id = p_org_id;

            SELECT global_attribute2
              INTO l_txn_reason_code
              FROM mtl_system_items mtl
             WHERE mtl.organization_id = l_def_from_org_id
               AND mtl.inventory_item_id = p_item_id
               AND ROWNUM = 1;

            IF l_txn_reason_code IS NOT NULL
            THEN
               --
               -- return if trx reason code is found at Master org
               --
               RETURN l_txn_reason_code;
            END IF;
         END IF;
      END IF;

      -- get here then 1 of the following is true
       -- p_item_id is NULL or
       -- p_item_id is not NULL but trx reason code is
       -- not available for Local/Master org
       -- need to get trx reason code from
       -- PO system parameters
       --
      SELECT global_attribute1
        INTO l_txn_reason_code
        FROM po_system_parameters_all
       WHERE org_id = p_org_id;

      RETURN l_txn_reason_code;
      DEBUG ('End populate_icx_trx_reason_code');
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG ('Error Code' || SQLCODE);
         DEBUG ('Error Message' || SQLERRM);
         RETURN ' ';
   END populate_icx_trx_reason_code;

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
