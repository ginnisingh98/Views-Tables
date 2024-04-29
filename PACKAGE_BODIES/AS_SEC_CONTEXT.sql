--------------------------------------------------------
--  DDL for Package Body AS_SEC_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SEC_CONTEXT" as
/* $Header: asseccxb.pls 115.1 2002/12/05 21:28:01 karaghav ship $ */

   PROCEDURE set_attr_values
     (p_attr_names IN VARCHAR2_TABLE_100,
      p_attr_vals IN VARCHAR2_TABLE_100
     )
   IS
    newrec sec_attr_record;
    BEGIN
        IF p_attr_names IS NOT null THEN
          IF p_attr_vals IS NOT null THEN
             IF p_attr_vals.COUNT = p_attr_names.COUNT THEN
               FOR i IN p_attr_names.FIRST .. p_attr_names.LAST
                 LOOP
                  newrec.sec_attr_name := p_attr_names(i);
                  newrec.sec_attr_value := p_attr_vals(i);
                  IF g_sec_attr_table IS NULL THEN
                     g_sec_attr_table := sec_attr_tbl(newrec);
                  ELSE
                     g_sec_Attr_table.EXTEND;
                     g_sec_attr_table(g_sec_attr_table.COUNT) := newrec;
                  END IF;
                END LOOP;
              END IF;
           END IF;
         END IF;
    END;

   PROCEDURE set_attr_value(
             p_attr_name IN VARCHAR2,
             p_attr_value IN VARCHAR2)
       IS
       newrec sec_attr_record;
       BEGIN
         if p_attr_name IS NOT NULL THEN
            if p_attr_value IS NOT NULL THEN
              newrec.sec_attr_name := p_attr_name;
              newrec.sec_attr_value := p_attr_value;
              if g_sec_attr_table IS NULL THEN
                g_sec_attr_table := sec_attr_tbl(newrec);
              else
                g_sec_attr_table.EXTEND;
                g_sec_attr_table(g_sec_attr_table.COUNT) := newrec;
              end if;
            end if;
          end if;
        END;

   FUNCTION get_attr_value
     ( p_attr_name VARCHAR2) RETURN VARCHAR2
     IS
           BEGIN
         IF g_sec_attr_table IS NULL THEN
           RETURN NULL;
         END IF;
         IF g_sec_attr_table.COUNT = 0 THEN
            RETURN NULL;
         ELSE
            FOR i IN g_sec_attr_table.FIRST .. g_sec_attr_table.LAST
              LOOP
                 IF g_sec_attr_table(i).sec_attr_name = p_attr_name THEN
                    RETURN g_sec_attr_table(i).sec_attr_value;
                 END IF;
              END LOOP;
            RETURN NULL;
         END IF;
       END;

   PROCEDURE INIT
   IS
     BEGIN
        g_sec_attr_table := NULL;
     END;

END;

/
