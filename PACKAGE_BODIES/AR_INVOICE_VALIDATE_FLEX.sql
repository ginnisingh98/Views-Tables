--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_VALIDATE_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_VALIDATE_FLEX" AS
/* $Header: ARXVINFB.pls 115.1 2003/12/30 00:30:49 anukumar noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE setup_descr_flex(
   p_appl_id   IN number,
   p_desc_flex IN varchar2)
IS

   cursor sel_active_segs( pc_appl_id in number,
                           pc_desc_flex in varchar2) is
      select ctx.descriptive_flex_context_code context_code,
             substr(seg.application_column_name,
                    length('INTERFACE_LINE_ATTRIBUTE')+1) segment_num
      from   fnd_descr_flex_contexts ctx,
             fnd_descr_flex_column_usages seg
      where  ctx.application_id = pc_appl_id
      and    ctx.descriptive_flexfield_name = pc_desc_flex
      and    ctx.application_id = seg.application_id(+)
      and    ctx.descriptive_flexfield_name =
                     seg.descriptive_flexfield_name(+)
      and    ctx.descriptive_flex_context_code =
                      seg.descriptive_flex_context_code(+)
      and    seg.enabled_flag (+) = 'Y'
      order by ctx.descriptive_flex_context_code, seg.column_seq_num;

  l_prior_context   fnd_descr_flex_contexts.descriptive_flex_context_code%type;
  l_ctx_count       number;
  l_seg_count       number;
  l_total_seg_count number;
  l_seg_number      number;

BEGIN

  l_prior_context := pg_char_dummy;
  l_ctx_count     := 0;
  l_total_seg_count := 1;

  IF pg_debug = 'Y'
  THEN
    ar_invoice_utils.debug('setup_descr_flex()+');
  END IF;

 /*----------------------------------------------------------------------+
  | get the active segment numbers for the transaction flex and store    |
  | the information in package globals                                   |
  +----------------------------------------------------------------------*/

  FOR segs IN sel_active_segs(p_appl_id, p_desc_flex)
  LOOP

     IF (segs.context_code <> l_prior_context)
     THEN

        l_seg_count := 0;
        l_ctx_count := l_ctx_count + 1;
        l_prior_context := segs.context_code;
        pg_num_segs(l_ctx_count) := 0;

        pg_flex_contexts(l_ctx_count) := segs.context_code;
        pg_start_loc(l_ctx_count) := l_total_seg_count;

     END IF;

     IF (segs.segment_num IS NOT NULL)
     THEN
        l_seg_count       := l_seg_count + 1;

        pg_active_segs(l_total_seg_count) := segs.segment_num;

        l_total_seg_count := l_total_seg_count + 1;
        pg_num_segs(l_ctx_count) := l_seg_count;

     END IF;
  END LOOP;

  pg_ctx_count := l_ctx_count;
  IF pg_debug = 'Y'
  THEN
    ar_invoice_utils.debug('setup_descr_flex()-');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : setup_descr_flex()');
        ar_invoice_utils.debug('p_appl_id      : '||p_appl_id);
        ar_invoice_utils.debug('p_desc_flex    : '||p_desc_flex);
    END IF;
    RAISE;
END setup_descr_flex;

FUNCTION find_context(p_context IN varchar2) RETURN number
IS
BEGIN

   FOR i IN 1..pg_ctx_count LOOP

      IF pg_flex_contexts(i) = p_context
      THEN
          return(i);
      END IF;

   END LOOP;

   return(0);

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : find_context()');
        ar_invoice_utils.debug('p_context      : '||p_context);
    END IF;
    RAISE;
END;

PROCEDURE build_where_clause (
                                p_context        IN      varchar2,
                                p_context_index  IN      BINARY_INTEGER,
                                p_where_clause   IN OUT NOCOPY  varchar2)

IS
  l_seg_num        number;
  l_first          boolean := TRUE;
  l_context_index  BINARY_INTEGER;
  l_context        ra_customer_trx_lines.interface_line_context%type;

BEGIN
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('build_where_clause()+');
   END IF;
   l_context := p_context;
   l_context_index := p_context_index;

   p_where_clause := '';


  /*-----------------------------------------------------------------+
   | Process the active segments for a context. The Global context   |
   | should be processed along with all contexts as global segments  |
   | are visible under all contexts                                  |
   +-----------------------------------------------------------------*/
   LOOP

      IF (l_context_index > 0)
      THEN

        /*------------------------------------------------------------+
         | For each of the active segments construct the WHERE clause |
         | based on the corresponding attribute value.                |
         +------------------------------------------------------------*/

         FOR i IN 1..pg_num_segs(l_context_index) LOOP

            l_seg_num := pg_active_segs(pg_start_loc(l_context_index)+i-1);

            IF (NOT l_first) THEN
               p_where_clause := p_where_clause||' AND ';
            ELSE
               l_first := FALSE;
            END IF;

          /*--------------------------------------------------------------+
           | If the attribute value is NULL, then construct the clause as |
           |     INTERFACE_LINE_ATTRIBUTE<seg_num> IS NULL                |
           | Otherwise                                                    |
           |     INTERFACE_LINE_ATTRIBUTE<seg_num> = <attribute value>    |
           +--------------------------------------------------------------*/

            p_where_clause := p_where_clause||
                              'INTERFACE_LINE_ATTRIBUTE'||
                              to_char(l_seg_num);

            p_where_clause := p_where_clause||
                                 ' = :INTERFACE_LINE_ATTRIBUTE'||
                                     to_char(l_seg_num);

         END LOOP;
      ELSE
          IF pg_debug = 'Y'
          THEN
                ar_invoice_utils.debug('AR', 'AR_INV_TRANS_FLEX_CONTEXT');
          END IF;
          app_exception.raise_exception;
      END IF;

      IF (l_context = 'Global Data Elements')
      THEN
          EXIT;
      ELSE
         l_context := 'Global Data Elements';
         l_context_index := Find_Context( l_context);
      END IF;

   END LOOP;
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('Where clause : '||p_where_clause);
        ar_invoice_utils.debug('build_where_clause()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : build_where_clause');
        ar_invoice_utils.debug('p_context      : '||p_context);
    END IF;
    RAISE;
END Build_where_clause;


FUNCTION Get_Cursor(
                      p_context_index   IN BINARY_INTEGER,
                      p_table_name      IN VARCHAR2
                    ) RETURN  BINARY_INTEGER  IS

   l_context       ra_customer_trx_lines.interface_line_context%type;
   l_stmt	   VARCHAR2(2000);
   l_where_clause  VARCHAR2(2000);
   l_cursor        BINARY_INTEGER;

BEGIN
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('Get_Cursor()+');
   END IF;

   l_context := pg_flex_contexts( p_context_index );

  /*-----------------------------+
   | construct the WHERE clause  |
   +-----------------------------*/
   build_where_clause( l_context,
                       p_context_index,
                       l_where_clause);


   IF (p_table_name = 'AR_TRX_LINES_GT')
   THEN   l_stmt := 'SELECT 0, 0 FROM '|| p_table_name;
   ELSE   l_stmt := 'SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID FROM '||
          p_table_name;
   END IF;

   IF (l_where_clause IS NOT NULL)
   THEN
     /*----------------------------------------------------------------+
      |  Construct additional WHERE clause based on the table that is  |
      |  being checked.                                                |
      |  For AR_TRX_LINES_GT, the context is always filled in even  |
      |  if it is a Global context and for RA_CUSTOMER_TRX_LINES the   |
      |  context is NULL if it is a Global context. Also, do not       |
      |  include the current row when checking the uniqueness of the   |
      |  transaction flex in RA_CUSTOMER_TRX_LINES                     |
      +----------------------------------------------------------------*/

      IF (p_table_name = 'AR_TRX_LINES_GT')
      THEN
          l_stmt := l_stmt||' WHERE interface_line_context = '''||
                    nvl(l_context, 'Global Data Elements')||'''';
          /*l_stmt := l_stmt||' AND  NVL(interface_status,''~'') <> ''P'''; */
      ELSIF (p_table_name = 'RA_CUSTOMER_TRX_LINES')
      THEN
          IF (nvl(l_context, 'Global Data Elements') = 'Global Data Elements')
          THEN
              l_stmt := l_stmt||' WHERE interface_line_context IS NULL ';
          ELSE
              l_stmt := l_stmt||' WHERE interface_line_context = '''||
                        l_context||'''';
          END IF;

          l_stmt := l_stmt||' AND customer_trx_line_id+0 <> '||
                                'NVL(:customer_trx_line_id, -98)';

      END IF;

      l_stmt := l_stmt || ' AND  '|| l_where_clause;

   END IF;
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('SQL Stmt : '||l_stmt);
   END IF;
  /*---------------------------------------------------+
   | Open, Parse and Execute the constructed SQL stmt  |
   +---------------------------------------------------*/

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_stmt, dbms_sql.v7);

   IF    (p_table_name = 'RA_CUSTOMER_TRX_LINES')
   THEN  pg_ctl_cursors( p_context_index ) := l_cursor;
   ELSE  pg_ril_cursors( p_context_index ) := l_cursor;
   END IF;
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('Get_Cursor()-');
   END IF;

   RETURN(l_cursor);

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : Get_Cursor()');
        ar_invoice_utils.debug('p_context_index  = ' || TO_CHAR( p_context_index));
        ar_invoice_utils.debug('p_table_name     = ' || p_table_name);
    END IF;
    RAISE;

END get_cursor;


PROCEDURE Bind_Variable(   p_cursor         IN INTEGER,
                           p_bind_variable  IN VARCHAR2,
                           p_value          IN VARCHAR2
                       ) IS
BEGIN
    IF pg_debug = 'Y'
    THEN
          ar_invoice_utils.debug('Bind_Variables()+');
    END IF;
          dbms_sql.bind_variable( p_cursor,
                                  p_bind_variable,
                                  p_value );
    IF pg_debug = 'Y'
    THEN
          ar_invoice_utils.debug('Bind_Variables()-');
    END IF;

EXCEPTION
      WHEN OTHERS THEN
          IF (SQLCODE = -1006)
          THEN NULL;
          ELSE
            IF pg_debug = 'Y'
            THEN
                ar_invoice_utils.debug('EXCEPTION : Bind_Variable()');
                ar_invoice_utils.debug('p_cursor         = ' || p_cursor);
                ar_invoice_utils.debug('p_bind_variable  = ' || p_bind_variable);
                ar_invoice_utils.debug('p_value          = ' || p_value);
            END IF;
            RAISE;
          END IF;

END Bind_Variable;



PROCEDURE Bind_All_Variables(
  p_ctl_cursor	            IN OUT NOCOPY  BINARY_INTEGER,
  p_ril_cursor              IN OUT NOCOPY  BINARY_INTEGER,
  p_context_index           IN      BINARY_INTEGER,
  p_customer_trx_line_id    IN ra_customer_trx_lines.customer_trx_line_id%type,
  p_interface_line_context    IN
                    ra_customer_trx_lines.interface_line_context%type,
  p_interface_line_attribute1 IN
                    ra_customer_trx_lines.interface_line_attribute1%type,
  p_interface_line_attribute2 IN
                    ra_customer_trx_lines.interface_line_attribute2%type,
  p_interface_line_attribute3 IN
                    ra_customer_trx_lines.interface_line_attribute3%type,
  p_interface_line_attribute4 IN
                    ra_customer_trx_lines.interface_line_attribute4%type,
  p_interface_line_attribute5 IN
                    ra_customer_trx_lines.interface_line_attribute5%type,
  p_interface_line_attribute6 IN
                    ra_customer_trx_lines.interface_line_attribute6%type,
  p_interface_line_attribute7 IN
                    ra_customer_trx_lines.interface_line_attribute7%type,
  p_interface_line_attribute8 IN
                    ra_customer_trx_lines.interface_line_attribute8%type,
  p_interface_line_attribute9 IN
                    ra_customer_trx_lines.interface_line_attribute9%type,
  p_interface_line_attribute10 IN
                    ra_customer_trx_lines.interface_line_attribute10%type,
  p_interface_line_attribute11 IN
                    ra_customer_trx_lines.interface_line_attribute11%type,
  p_interface_line_attribute12 IN
                    ra_customer_trx_lines.interface_line_attribute12%type,
  p_interface_line_attribute13 IN
                    ra_customer_trx_lines.interface_line_attribute13%type,
  p_interface_line_attribute14 IN
                    ra_customer_trx_lines.interface_line_attribute14%type,
  p_interface_line_attribute15 IN
                    ra_customer_trx_lines.interface_line_attribute15%type) IS
BEGIN

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('Bind_All_Variables()+');
    END IF;


   /*-------------------------------------------------------+
    |  Bind variables into the ra_customer_trx_line cursor  |
    +-------------------------------------------------------*/

     BEGIN
          Bind_Variable(
                         p_ctl_cursor,
                         ':CUSTOMER_TRX_LINE_ID',
                         p_customer_trx_line_id
                       );
     EXCEPTION

       /*-----------------------------------------------------------+
        |  If the cursor is invalid, the first bind will fail.      |
        |  in that case, recreate and reparse the SQL statement     |
        |  and continue processing. The new cursor is passed back   |
        |  to the calling routine since it is an IN/OUT parameter.  |
	    +-----------------------------------------------------------*/

        WHEN INVALID_CURSOR THEN
             IF pg_debug = 'Y'
             THEN
                    ar_invoice_utils.debug('Handling INVALID_CURSOR exception by reparsing');
             END IF;

             p_ctl_cursor := Get_Cursor(
                                         p_context_index,
                                         'RA_CUSTOMER_TRX_LINES'
                                       );

             Bind_Variable(
                            p_ctl_cursor,
                            ':CUSTOMER_TRX_LINE_ID',
                            p_customer_trx_line_id
                          );

        WHEN OTHERS THEN RAISE;
     END;


     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE1',
                    p_interface_line_attribute1
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE2',
                    p_interface_line_attribute2
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE3',
                    p_interface_line_attribute3
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE4',
                    p_interface_line_attribute4
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE5',
                    p_interface_line_attribute5
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE6',
                    p_interface_line_attribute6
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE7',
                    p_interface_line_attribute7
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE8',
                    p_interface_line_attribute8
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE9',
                    p_interface_line_attribute9
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE10',
                    p_interface_line_attribute10
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE11',
                    p_interface_line_attribute11
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE12',
                    p_interface_line_attribute12
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE13',
                    p_interface_line_attribute13
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE14',
                    p_interface_line_attribute14
                  );

     Bind_Variable(
                    p_ctl_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE15',
                    p_interface_line_attribute15
                  );

   /*-----------------------------------------------------+
    |  Bind variables into the AR_TRX_LINES_GT cursor  |
    +-----------------------------------------------------*/

     BEGIN
           Bind_Variable(
                          p_ril_cursor,
                          ':CUSTOMER_TRX_LINE_ID',
                          p_customer_trx_line_id
                        );

     EXCEPTION

       /*-----------------------------------------------------------+
        |  If the cursor is invalid, the first bind will fail.      |
        |  in that case, recreate and reparse the SQL statement     |
        |  and continue processing. The new cursor is passed back   |
        |  to the calling routine since it is an IN/OUT parameter.  |
	+-----------------------------------------------------------*/

        WHEN INVALID_CURSOR THEN
             IF pg_debug = 'Y'
             THEN
                ar_invoice_utils.debug('Handling INVALID_CURSOR exception by reparsing');
             END IF;

             p_ril_cursor := Get_Cursor(
                                         p_context_index,
                                         'AR_TRX_LINES_GT'
                                       );

             Bind_Variable(
                            p_ril_cursor,
                            ':CUSTOMER_TRX_LINE_ID',
                            p_customer_trx_line_id
                          );

        WHEN OTHERS THEN RAISE;
     END;


     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE1',
                    p_interface_line_attribute1
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE2',
                    p_interface_line_attribute2
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE3',
                    p_interface_line_attribute3
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE4',
                    p_interface_line_attribute4
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE5',
                    p_interface_line_attribute5
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE6',
                    p_interface_line_attribute6
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE7',
                    p_interface_line_attribute7
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE8',
                    p_interface_line_attribute8
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE9',
                    p_interface_line_attribute9
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE10',
                    p_interface_line_attribute10
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE11',
                    p_interface_line_attribute11
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE12',
                    p_interface_line_attribute12
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE13',
                    p_interface_line_attribute13
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE14',
                    p_interface_line_attribute14
                  );

     Bind_Variable(
                    p_ril_cursor,
                    ':INTERFACE_LINE_ATTRIBUTE15',
                    p_interface_line_attribute15
                  );

     IF pg_debug = 'Y'
     THEN
            ar_invoice_utils.debug('Bind_All_Variables()-');
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : Bind_All_Variables');
        ar_invoice_utils.debug('p_ctl_cursor                  : ' || p_ctl_cursor);
        ar_invoice_utils.debug('p_ril_cursor                  : ' || p_ctl_cursor);
        ar_invoice_utils.debug('p_customer_trx_line_id        : '||p_customer_trx_line_id);
        ar_invoice_utils.debug('p_interface_line_context      : '||
                                         p_interface_line_context);
        ar_invoice_utils.debug('p_interface_line_attribute2   : '||
                                         p_interface_line_attribute2);
        ar_invoice_utils.debug('p_interface_line_attribute3   : '||
                                         p_interface_line_attribute3);
        ar_invoice_utils.debug('p_interface_line_attribute4   : '||
                                         p_interface_line_attribute4);
        ar_invoice_utils.debug('p_interface_line_attribute5   : '||
                                         p_interface_line_attribute5);
        ar_invoice_utils.debug('p_interface_line_attribute6   : '||
                                         p_interface_line_attribute6);
        ar_invoice_utils.debug('p_interface_line_attribute7   : '||
                                         p_interface_line_attribute7);
        ar_invoice_utils.debug('p_interface_line_attribute8   : '||
                                         p_interface_line_attribute8);
        ar_invoice_utils.debug('p_interface_line_attribute9   : '||
                                         p_interface_line_attribute9);
        ar_invoice_utils.debug('p_interface_line_attribute10  : '||
                                         p_interface_line_attribute10);
        ar_invoice_utils.debug('p_interface_line_attribute11  : '||
                                         p_interface_line_attribute11);
        ar_invoice_utils.debug('p_interface_line_attribute12  : '||
                                         p_interface_line_attribute12);
        ar_invoice_utils.debug('p_interface_line_attribute13  : '||
                                         p_interface_line_attribute13);
        ar_invoice_utils.debug('p_interface_line_attribute14  : '||
                                         p_interface_line_attribute14);
        ar_invoice_utils.debug('p_interface_line_attribute15  : '||
                                         p_interface_line_attribute15);
    END IF;
    RAISE;

END Bind_All_Variables;

FUNCTION check_uniqueness(
                           p_table_name            IN  VARCHAR2,
                           p_cursor                IN OUT NOCOPY BINARY_INTEGER,
                           p_customer_trx_id       OUT NOCOPY
                                         ra_customer_trx.customer_trx_id%type,
                           p_customer_trx_line_id  OUT NOCOPY
                               ra_customer_trx_lines.customer_trx_line_id%type
                         ) RETURN boolean
IS
  l_dummy                 BINARY_INTEGER;
  l_customer_trx_id       ra_customer_trx.customer_trx_id%type;
  l_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%type;
  l_rows                  NUMBER;

BEGIN

   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('check_uniqueness()+');
   END IF;

   dbms_sql.define_column( p_cursor, 1, l_customer_trx_id);
   dbms_sql.define_column( p_cursor, 2, l_customer_trx_line_id);

   l_dummy := dbms_sql.execute(p_cursor);
   l_rows  := dbms_sql.fetch_rows(p_cursor);


  /*-------------------------------------------------------------+
   | If more than one matching rows are found then the flex is   |
   | non-unique,                                                 |
   | return FALSE. Otherwise return TRUE                         |
   +-------------------------------------------------------------*/

   IF (l_rows > 0 and p_table_name = 'RA_CUSTOMER_TRX_LINES' )
   THEN
       dbms_sql.column_value( p_cursor, 1, l_customer_trx_id);
       dbms_sql.column_value( p_cursor, 2, l_customer_trx_line_id);
       p_customer_trx_id      := l_customer_trx_id;
       p_customer_trx_line_id := l_customer_trx_line_id;

       IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug('check_uniqueness()-');
       END IF;
       return(FALSE);
   ELSIF ( l_rows > 1 and p_table_name = 'AR_TRX_LINES_GT' )
   THEN
        dbms_sql.column_value( p_cursor, 1, l_customer_trx_id);
        dbms_sql.column_value( p_cursor, 2, l_customer_trx_line_id);
        p_customer_trx_id      := l_customer_trx_id;
        p_customer_trx_line_id := l_customer_trx_line_id;
        IF pg_debug = 'Y'
        THEN
            ar_invoice_utils.debug('check_uniqueness for ar_trx_lines_gt()-');
        END IF;
       return(FALSE);
   END IF;

   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('check_uniqueness()-');
   END IF;
   return(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : check_uniqueness()');
        ar_invoice_utils.debug('p_cursor     : '|| p_cursor);
    END IF;
    IF (p_cursor IS NOT NULL)
    THEN dbms_sql.close_cursor(p_cursor);
    END IF;

    RAISE;
END check_uniqueness;


FUNCTION unique_flex(
  p_ctl_id                    IN
                        ra_customer_trx_lines.customer_trx_line_id%type,
  p_customer_trx_id           IN    NUMBER,
  p_customer_trx_line_id      IN    NUMBER,
  p_int_line_rec              IN
                    interface_line_rec_type )
RETURN boolean IS

  l_seg_value      seg_value_type;
  l_where_clause   varchar2(1000);
  l_ctl_cursor     BINARY_INTEGER;
  l_ril_cursor     BINARY_INTEGER;
  l_context_index  BINARY_INTEGER;
  l_dummy          BINARY_INTEGER;
  l_customer_trx_id NUMBER;
  l_customer_trx_line_id  NUMBER;
BEGIN
   IF pg_debug = 'Y'
   THEN
        ar_invoice_utils.debug('unique_trans_flex()+');
   END IF;
     setup_descr_flex(222, 'RA_INTERFACE_LINES');

  /*------------------------------------------------+
   |  Get the context index from the context cache  |
   +------------------------------------------------*/

   l_context_index := Find_Context(
                                    nvl(p_int_line_rec.interface_line_context,
                                       'Global Data Elements')
                                  );

  /*------------------------------------------------------------------+
   |  Reuse the existing cursors if they exist. Otherwise, create and |
   |  parse the SQL statements into new cursors.                      |
   +------------------------------------------------------------------*/

   BEGIN
      l_ctl_cursor := pg_ctl_cursors( l_context_index );

   EXCEPTION
      WHEN NO_DATA_FOUND
           THEN

            l_ctl_cursor := Get_Cursor(
                                             l_context_index,
                                             'RA_CUSTOMER_TRX_LINES'
                                          );

      WHEN OTHERS THEN RAISE;
   END;


   BEGIN

      l_ril_cursor := pg_ril_cursors( l_context_index );

   EXCEPTION
      WHEN NO_DATA_FOUND

           THEN

            l_ril_cursor := Get_Cursor(
                                             l_context_index,
                                             'AR_TRX_LINES_GT' );

      WHEN OTHERS THEN RAISE;
   END;

   Bind_All_Variables(
                       l_ctl_cursor,
                       l_ril_cursor,
                       l_context_index,
                       p_ctl_id,
                       p_int_line_rec.interface_line_context,
                       p_int_line_rec.interface_line_attribute1,
                       p_int_line_rec.interface_line_attribute2,
                       p_int_line_rec.interface_line_attribute3,
                       p_int_line_rec.interface_line_attribute4,
                       p_int_line_rec.interface_line_attribute5,
                       p_int_line_rec.interface_line_attribute6,
                       p_int_line_rec.interface_line_attribute7,
                       p_int_line_rec.interface_line_attribute8,
                       p_int_line_rec.interface_line_attribute9,
                       p_int_line_rec.interface_line_attribute10,
                       p_int_line_rec.interface_line_attribute11,
                       p_int_line_rec.interface_line_attribute12,
                       p_int_line_rec.interface_line_attribute13,
                       p_int_line_rec.interface_line_attribute14,
                       p_int_line_rec.interface_line_attribute15
                    );
  /*----------------------------------------------------------------------+
   | check for the uniqueness of the flex in RA_CUSTOMER_TRX_LINES table  |
   +----------------------------------------------------------------------*/
   IF (NOT check_uniqueness(
                             'RA_CUSTOMER_TRX_LINES',
                             l_ctl_cursor,
                             l_customer_trx_id,
                             l_customer_trx_line_id
                           ) )
   THEN
       return(FALSE);
   END IF;

  /*----------------------------------------------------------------------+
   | check for the uniqueness of the flex in AR_TRX_LINES_GT    table  |
   +----------------------------------------------------------------------*/
   IF (NOT check_uniqueness(
                             'AR_TRX_LINES_GT',
                             l_ril_cursor,
                             l_dummy,
                             l_dummy
                           ) )
   THEN
       return(FALSE);
   END IF;

   return(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug('EXCEPTION : arp_invoice_validate_flex.unique_flex');
    END IF;
    RAISE;

END unique_flex;

PROCEDURE Validate_Line_Int_Flex(
    p_desc_flex_rec         IN OUT NOCOPY  interface_line_rec_type,
    p_desc_flex_name        IN VARCHAR2,
    p_return_status         IN OUT NOCOPY  varchar2
                         ) IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name     VARCHAR2(50);
l_flex_exists  VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = 222
    and descriptive_flexfield_name = p_desc_flex_name;
BEGIN
      IF PG_DEBUG = 'Y' THEN
         ar_invoice_utils.debug('' || 'AR_INVOICE_UTILS.Validate_LINE_Int_Flex ()+');
      END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
       p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;

    IF p_desc_flex_name = 'RA_INTERCACE_LINES'
    THEN
        fnd_flex_descval.set_context_value(p_desc_flex_rec.interface_line_context);

        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE1',
                                p_desc_flex_rec.interface_LINE_attribute1);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE2',
                                p_desc_flex_rec.interface_LINE_attribute2);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE3',
                                p_desc_flex_rec.interface_LINE_attribute3);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE4',
                                p_desc_flex_rec.interface_LINE_attribute4);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE5',
                                p_desc_flex_rec.interface_LINE_attribute5);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE6',
                                p_desc_flex_rec.interface_LINE_attribute6);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE7',
                                p_desc_flex_rec.interface_LINE_attribute7);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE8',
                                p_desc_flex_rec.interface_LINE_attribute8);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE9',
                                p_desc_flex_rec.interface_LINE_attribute9);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE10',
                                p_desc_flex_rec.interface_LINE_attribute10);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE11',
                                p_desc_flex_rec.interface_LINE_attribute11);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE12',
                                p_desc_flex_rec.interface_LINE_attribute12);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE13',
                                p_desc_flex_rec.interface_LINE_attribute13);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE14',
                                p_desc_flex_rec.interface_LINE_attribute14);
        fnd_flex_descval.set_column_value('INTERFACE_LINE_ATTRIBUTE15',
                                p_desc_flex_rec.interface_LINE_attribute15);


        IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_count := fnd_flex_descval.segment_count;


        FOR i in 1..l_count LOOP
            l_col_name := fnd_flex_descval.segment_column_name(i);

            IF l_col_name = 'INTERFACE_LINE_ATTRIBUTE1' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute1 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_CONTEXT'  THEN
                p_desc_flex_rec.interface_LINE_context := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE2' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute2 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE3' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute3 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE4' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute4 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE5' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute5 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE6' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute6 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE7' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute7 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE8' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute8 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE9' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute9 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE10' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute10 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE11' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute11 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE12' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute12 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE13' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute13 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE14' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute14 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_LINE_ATTRIBUTE15' THEN
                p_desc_flex_rec.INTERFACE_LINE_attribute15 := fnd_flex_descval.segment_id(i);
            END IF;

            IF i > l_count  THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

END Validate_Line_Int_Flex;



PROCEDURE Validate_Int_Desc_Flex(
    p_desc_flex_rec       IN OUT NOCOPY  interface_hdr_rec_type,
    p_desc_flex_name      IN VARCHAR2,
    p_return_status       IN OUT NOCOPY  varchar2
                         ) IS

l_flex_name     fnd_descriptive_flexs.descriptive_flexfield_name%type;
l_count         NUMBER;
l_col_name     VARCHAR2(50);
l_flex_exists  VARCHAR2(1);
CURSOR desc_flex_exists IS
  SELECT 'Y'
  FROM fnd_descriptive_flexs
  WHERE application_id = 222
    and descriptive_flexfield_name = p_desc_flex_name;
BEGIN
      IF PG_DEBUG = 'Y' THEN
         ar_invoice_utils.debug('' || 'AR_INVOICE_UTILS.Validate_Int_Desc_Flex ()+');
      END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN desc_flex_exists;
      FETCH desc_flex_exists INTO l_flex_exists;
      IF desc_flex_exists%NOTFOUND THEN
       CLOSE desc_flex_exists;
       p_return_status :=  FND_API.G_RET_STS_ERROR;
       return;
      END IF;
      CLOSE desc_flex_exists;

    IF p_desc_flex_name = 'RA_INTERFACE_HEADER'
    THEN
        fnd_flex_descval.set_context_value(p_desc_flex_rec.interface_header_context);

        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE1',
                                p_desc_flex_rec.interface_header_attribute1);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE2',
                                p_desc_flex_rec.interface_header_attribute2);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE3',
                                p_desc_flex_rec.interface_header_attribute3);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE4',
                                p_desc_flex_rec.interface_header_attribute4);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE5',
                                p_desc_flex_rec.interface_header_attribute5);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE6',
                                p_desc_flex_rec.interface_header_attribute6);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE7',
                                p_desc_flex_rec.interface_header_attribute7);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE8',
                                p_desc_flex_rec.interface_header_attribute8);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE9',
                                p_desc_flex_rec.interface_header_attribute9);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE10',
                                p_desc_flex_rec.interface_header_attribute10);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE11',
                                p_desc_flex_rec.interface_header_attribute11);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE12',
                                p_desc_flex_rec.interface_header_attribute12);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE13',
                                p_desc_flex_rec.interface_header_attribute13);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE14',
                                p_desc_flex_rec.interface_header_attribute14);
        fnd_flex_descval.set_column_value('INTERFACE_HEADER_ATTRIBUTE15',
                                p_desc_flex_rec.interface_header_attribute15);


        IF ( NOT fnd_flex_descval.validate_desccols('AR',p_desc_flex_name,'I') )
        THEN
            p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_count := fnd_flex_descval.segment_count;


        FOR i in 1..l_count LOOP
            l_col_name := fnd_flex_descval.segment_column_name(i);

            IF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE1' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute1 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_CONTEXT'  THEN
                p_desc_flex_rec.interface_header_context := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE2' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute2 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE3' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute3 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE4' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute4 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE5' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute5 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE6' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute6 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE7' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute7 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE8' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute8 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE9' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute9 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE10' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute10 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE11' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute11 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE12' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute12 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE13' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute13 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE14' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute14 := fnd_flex_descval.segment_id(i);
            ELSIF l_col_name = 'INTERFACE_HEADER_ATTRIBUTE15' THEN
                p_desc_flex_rec.INTERFACE_HEADER_attribute15 := fnd_flex_descval.segment_id(i);
            END IF;

            IF i > l_count  THEN
                EXIT;
            END IF;
        END LOOP;
    END IF;

END Validate_Int_Desc_Flex;


PROCEDURE validate_desc_flex (
    p_validation_type   IN  VARCHAR2,
    x_errmsg            OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2 ) AS

    --p_trx_attr_rec
    p_trx_attr_rec              arp_util.attribute_rec_type;
    p_trx_hdr_int_attr_rec      interface_hdr_rec_type;
    p_trx_line_int_attr_rec     interface_line_rec_type;

    CURSOR cFlexAttr IS
        SELECT attribute1, attribute2, attribute3,
               attribute4, attribute5, attribute6,
               attribute7, attribute8, attribute9,
               attribute10, attribute11, attribute12,
               attribute13, attribute14, attribute15,
               attribute_category,
               trx_header_id
        FROM   ar_trx_header_gt
        WHERE  attribute1 IS NOT NULL
        OR     attribute2 IS NOT NULL
        OR     attribute3 IS NOT NULL
        OR     attribute4 IS NOT NULL
        OR     attribute5 IS NOT NULL
        OR     attribute6 IS NOT NULL
        OR     attribute7 IS NOT NULL
        OR     attribute8 IS NOT NULL
        OR     attribute9 IS NOT NULL
        OR     attribute10 IS NOT NULL
        OR     attribute11 IS NOT NULL
        OR     attribute12 IS NOT NULL
        OR     attribute13 IS NOT NULL
        OR     attribute14 IS NOT NULL
        OR     attribute15 IS NOT NULL;

    CURSOR cFlexIntAttr IS
        SELECT interface_header_attribute1,
               interface_header_attribute2,
               interface_header_attribute3,
               interface_header_attribute4,
               interface_header_attribute5,
               interface_header_attribute6,
               interface_header_attribute7,
               interface_header_attribute8,
               interface_header_attribute9,
               interface_header_attribute10,
               interface_header_attribute11,
               interface_header_attribute12,
               interface_header_attribute13,
               interface_header_attribute14,
               interface_header_attribute15,
               interface_header_context,
               trx_header_id
        FROM   ar_trx_header_gt
        WHERE  interface_header_attribute1 IS NOT NULL
        OR     interface_header_attribute2 IS NOT NULL
        OR     interface_header_attribute3 IS NOT NULL
        OR     interface_header_attribute4 IS NOT NULL
        OR     interface_header_attribute5 IS NOT NULL
        OR     interface_header_attribute6 IS NOT NULL
        OR     interface_header_attribute7 IS NOT NULL
        OR     interface_header_attribute8 IS NOT NULL
        OR     interface_header_attribute9 IS NOT NULL
        OR     interface_header_attribute10 IS NOT NULL
        OR     interface_header_attribute11 IS NOT NULL
        OR     interface_header_attribute12 IS NOT NULL
        OR     interface_header_attribute13 IS NOT NULL
        OR     interface_header_attribute14 IS NOT NULL
        OR     interface_header_attribute15 IS NOT NULL;

    CURSOR clFlexIntAttr IS
        SELECT interface_line_attribute1,
               interface_line_attribute2,
               interface_line_attribute3,
               interface_line_attribute4,
               interface_line_attribute5,
               interface_line_attribute6,
               interface_line_attribute7,
               interface_line_attribute8,
               interface_line_attribute9,
               interface_line_attribute10,
               interface_line_attribute11,
               interface_line_attribute12,
               interface_line_attribute13,
               interface_line_attribute14,
               interface_line_attribute15,
               interface_line_context,
               trx_header_id,
               trx_line_id,
               customer_trx_line_id,
               customer_trx_id
        FROM   ar_trx_lines_gt
        WHERE  interface_line_attribute1 IS NOT NULL
        OR     interface_line_attribute2 IS NOT NULL
        OR     interface_line_attribute3 IS NOT NULL
        OR     interface_line_attribute4 IS NOT NULL
        OR     interface_line_attribute5 IS NOT NULL
        OR     interface_line_attribute6 IS NOT NULL
        OR     interface_line_attribute7 IS NOT NULL
        OR     interface_line_attribute8 IS NOT NULL
        OR     interface_line_attribute9 IS NOT NULL
        OR     interface_line_attribute10 IS NOT NULL
        OR     interface_line_attribute11 IS NOT NULL
        OR     interface_line_attribute12 IS NOT NULL
        OR     interface_line_attribute13 IS NOT NULL
        OR     interface_line_attribute14 IS NOT NULL
        OR     interface_line_attribute15 IS NOT NULL;

    CURSOR clFlexAttr IS
        SELECT attribute1, attribute2, attribute3,
               attribute4, attribute5, attribute6,
               attribute7, attribute8, attribute9,
               attribute10, attribute11, attribute12,
               attribute13, attribute14, attribute15,
               attribute_category,
               trx_header_id,
               trx_line_id
        FROM   ar_trx_lines_gt
        WHERE  attribute1 IS NOT NULL
        OR     attribute2 IS NOT NULL
        OR     attribute3 IS NOT NULL
        OR     attribute4 IS NOT NULL
        OR     attribute5 IS NOT NULL
        OR     attribute6 IS NOT NULL
        OR     attribute7 IS NOT NULL
        OR     attribute8 IS NOT NULL
        OR     attribute9 IS NOT NULL
        OR     attribute10 IS NOT NULL
        OR     attribute11 IS NOT NULL
        OR     attribute12 IS NOT NULL
        OR     attribute13 IS NOT NULL
        OR     attribute14 IS NOT NULL
        OR     attribute15 IS NOT NULL;

    CURSOR cdFlexAttr IS
        SELECT attribute1, attribute2, attribute3,
               attribute4, attribute5, attribute6,
               attribute7, attribute8, attribute9,
               attribute10, attribute11, attribute12,
               attribute13, attribute14, attribute15,
               attribute_category,
               trx_header_id,
               trx_line_id,
               trx_dist_id
        FROM   ar_trx_dist_gt
        WHERE  attribute1 IS NOT NULL
        OR     attribute2 IS NOT NULL
        OR     attribute3 IS NOT NULL
        OR     attribute4 IS NOT NULL
        OR     attribute5 IS NOT NULL
        OR     attribute6 IS NOT NULL
        OR     attribute7 IS NOT NULL
        OR     attribute8 IS NOT NULL
        OR     attribute9 IS NOT NULL
        OR     attribute10 IS NOT NULL
        OR     attribute11 IS NOT NULL
        OR     attribute12 IS NOT NULL
        OR     attribute13 IS NOT NULL
        OR     attribute14 IS NOT NULL
        OR     attribute15 IS NOT NULL;

    CURSOR csFlexAttr IS
        SELECT attribute1, attribute2, attribute3,
               attribute4, attribute5, attribute6,
               attribute7, attribute8, attribute9,
               attribute10, attribute11, attribute12,
               attribute13, attribute14, attribute15,
               attribute_category,
               trx_header_id,
               trx_line_id,
               trx_salescredit_id
        FROM   ar_trx_salescredits_gt
        WHERE  attribute1 IS NOT NULL
        OR     attribute2 IS NOT NULL
        OR     attribute3 IS NOT NULL
        OR     attribute4 IS NOT NULL
        OR     attribute5 IS NOT NULL
        OR     attribute6 IS NOT NULL
        OR     attribute7 IS NOT NULL
        OR     attribute8 IS NOT NULL
        OR     attribute9 IS NOT NULL
        OR     attribute10 IS NOT NULL
        OR     attribute11 IS NOT NULL
        OR     attribute12 IS NOT NULL
        OR     attribute13 IS NOT NULL
        OR     attribute14 IS NOT NULL
        OR     attribute15 IS NOT NULL;
BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_UTILS.validate_hd_desc_flex (+)' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call flex validation rtn for all header
    IF p_validation_type = 'HEADER'
    THEN
        FOR cFlexAttrRec IN cFlexAttr
        LOOP
            p_trx_attr_rec.attribute_category := cFlexAttrRec.attribute_category;
            p_trx_attr_rec.attribute1 := cFlexAttrRec.attribute1;
            p_trx_attr_rec.attribute2 := cFlexAttrRec.attribute2;
            p_trx_attr_rec.attribute3 := cFlexAttrRec.attribute3;
            p_trx_attr_rec.attribute4 := cFlexAttrRec.attribute4;
            p_trx_attr_rec.attribute5 := cFlexAttrRec.attribute5;
            p_trx_attr_rec.attribute6 := cFlexAttrRec.attribute6;
            p_trx_attr_rec.attribute7 := cFlexAttrRec.attribute7;
            p_trx_attr_rec.attribute8 := cFlexAttrRec.attribute8;
            p_trx_attr_rec.attribute9 := cFlexAttrRec.attribute9;
            p_trx_attr_rec.attribute10 := cFlexAttrRec.attribute10;
            p_trx_attr_rec.attribute11 := cFlexAttrRec.attribute11;
            p_trx_attr_rec.attribute12 := cFlexAttrRec.attribute12;
            p_trx_attr_rec.attribute13 := cFlexAttrRec.attribute13;
            p_trx_attr_rec.attribute14 := cFlexAttrRec.attribute14;
            p_trx_attr_rec.attribute15 := cFlexAttrRec.attribute15;

            arp_util.Validate_Desc_Flexfield(
                p_desc_flex_rec       => p_trx_attr_rec,
                p_desc_flex_name      => 'RA_CUSTOMER_TRX',
                p_return_status       => x_return_status );

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        error_message,
                        invalid_value) values (
                    cFlexAttrRec.trx_header_id,
                    arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                    'RA_CUSTOMER_TRX') ;
            END IF;
        END LOOP;

        FOR cFlexIntAttrRec IN cFlexIntAttr
        LOOP
            p_trx_hdr_int_attr_rec.interface_header_context := cFlexIntAttrRec.interface_header_context;
            p_trx_hdr_int_attr_rec.interface_header_attribute1 := cFlexIntAttrRec.interface_header_attribute1;
            p_trx_hdr_int_attr_rec.interface_header_attribute2 := cFlexIntAttrRec.interface_header_attribute2;
            p_trx_hdr_int_attr_rec.interface_header_attribute3 := cFlexIntAttrRec.interface_header_attribute3;
            p_trx_hdr_int_attr_rec.interface_header_attribute4 := cFlexIntAttrRec.interface_header_attribute4;
            p_trx_hdr_int_attr_rec.interface_header_attribute5 := cFlexIntAttrRec.interface_header_attribute5;
            p_trx_hdr_int_attr_rec.interface_header_attribute6 := cFlexIntAttrRec.interface_header_attribute6;
            p_trx_hdr_int_attr_rec.interface_header_attribute7 := cFlexIntAttrRec.interface_header_attribute7;
            p_trx_hdr_int_attr_rec.interface_header_attribute8 := cFlexIntAttrRec.interface_header_attribute8;
            p_trx_hdr_int_attr_rec.interface_header_attribute9 := cFlexIntAttrRec.interface_header_attribute9;
            p_trx_hdr_int_attr_rec.interface_header_attribute10 := cFlexIntAttrRec.interface_header_attribute10;
            p_trx_hdr_int_attr_rec.interface_header_attribute11 := cFlexIntAttrRec.interface_header_attribute11;
            p_trx_hdr_int_attr_rec.interface_header_attribute12 := cFlexIntAttrRec.interface_header_attribute12;
            p_trx_hdr_int_attr_rec.interface_header_attribute13 := cFlexIntAttrRec.interface_header_attribute13;
            p_trx_hdr_int_attr_rec.interface_header_attribute14 := cFlexIntAttrRec.interface_header_attribute14;
            p_trx_hdr_int_attr_rec.interface_header_attribute15 := cFlexIntAttrRec.interface_header_attribute15;

            Validate_int_Desc_Flex(
                p_desc_flex_rec       => p_trx_hdr_int_attr_rec,
                p_desc_flex_name      => 'RA_INTERFACE_HEADER',
                p_return_status       => x_return_status );
            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        error_message,
                        invalid_value) VALUES (
                 cFlexIntAttrRec.trx_header_id,
                  arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                  'RA_INTERFACE_HEADER') ;
            END IF;
        END LOOP;
    ELSIF p_validation_type = 'LINES'
    THEN
        FOR clFlexAttrRec IN clFlexAttr
        LOOP
            p_trx_attr_rec.attribute_category := clFlexAttrRec.attribute_category;
            p_trx_attr_rec.attribute1 := clFlexAttrRec.attribute1;
            p_trx_attr_rec.attribute2 := clFlexAttrRec.attribute2;
            p_trx_attr_rec.attribute3 := clFlexAttrRec.attribute3;
            p_trx_attr_rec.attribute4 := clFlexAttrRec.attribute4;
            p_trx_attr_rec.attribute5 := clFlexAttrRec.attribute5;
            p_trx_attr_rec.attribute6 := clFlexAttrRec.attribute6;
            p_trx_attr_rec.attribute7 := clFlexAttrRec.attribute7;
            p_trx_attr_rec.attribute8 := clFlexAttrRec.attribute8;
            p_trx_attr_rec.attribute9 := clFlexAttrRec.attribute9;
            p_trx_attr_rec.attribute10 := clFlexAttrRec.attribute10;
            p_trx_attr_rec.attribute11 := clFlexAttrRec.attribute11;
            p_trx_attr_rec.attribute12 := clFlexAttrRec.attribute12;
            p_trx_attr_rec.attribute13 := clFlexAttrRec.attribute13;
            p_trx_attr_rec.attribute14 := clFlexAttrRec.attribute14;
            p_trx_attr_rec.attribute15 := clFlexAttrRec.attribute15;

            arp_util.Validate_Desc_Flexfield(
                p_desc_flex_rec       => p_trx_attr_rec,
                p_desc_flex_name      => 'RA_CUSTOMER_TRX_LINES',
                p_return_status       => x_return_status );

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        trx_line_id,
                        error_message,
                        invalid_value) values (
                    clFlexAttrRec.trx_header_id,
                    clFlexAttrRec.trx_line_id,
                    arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                    'RA_CUSTOMER_TRX_LINES') ;
            END IF;
        END LOOP;

        FOR clFlexIntAttrRec IN clFlexIntAttr
        LOOP
            p_trx_line_int_attr_rec.interface_line_context := clFlexIntAttrRec.interface_line_context;
            p_trx_line_int_attr_rec.interface_line_attribute1 := clFlexIntAttrRec.interface_line_attribute1;
            p_trx_line_int_attr_rec.interface_line_attribute2 := clFlexIntAttrRec.interface_line_attribute2;
            p_trx_line_int_attr_rec.interface_line_attribute3 := clFlexIntAttrRec.interface_line_attribute3;
            p_trx_line_int_attr_rec.interface_line_attribute4 := clFlexIntAttrRec.interface_line_attribute4;
            p_trx_line_int_attr_rec.interface_line_attribute5 := clFlexIntAttrRec.interface_line_attribute5;
            p_trx_line_int_attr_rec.interface_line_attribute6 := clFlexIntAttrRec.interface_line_attribute6;
            p_trx_line_int_attr_rec.interface_line_attribute7 := clFlexIntAttrRec.interface_line_attribute7;
            p_trx_line_int_attr_rec.interface_line_attribute8 := clFlexIntAttrRec.interface_line_attribute8;
            p_trx_line_int_attr_rec.interface_line_attribute9 := clFlexIntAttrRec.interface_line_attribute9;
            p_trx_line_int_attr_rec.interface_line_attribute10 := clFlexIntAttrRec.interface_line_attribute10;
            p_trx_line_int_attr_rec.interface_line_attribute11 := clFlexIntAttrRec.interface_line_attribute11;
            p_trx_line_int_attr_rec.interface_line_attribute12 := clFlexIntAttrRec.interface_line_attribute12;
            p_trx_line_int_attr_rec.interface_line_attribute13 := clFlexIntAttrRec.interface_line_attribute13;
            p_trx_line_int_attr_rec.interface_line_attribute14 := clFlexIntAttrRec.interface_line_attribute14;
            p_trx_line_int_attr_rec.interface_line_attribute15 := clFlexIntAttrRec.interface_line_attribute15;

            -- first validate the uniqueness
            IF ( NOT unique_flex(
                p_ctl_id            => clFlexIntAttrRec.customer_trx_line_id,
                p_customer_trx_id   => clFlexIntAttrRec.customer_trx_id,
                p_customer_trx_line_id => clFlexIntAttrRec.customer_trx_line_id,
                p_int_line_rec      => p_trx_line_int_attr_rec) )
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        trx_line_id,
                        error_message,
                        invalid_value) VALUES (
                 clFlexIntAttrRec.trx_header_id,
                 clFlexIntAttrRec.trx_line_id,
                  arp_standard.fnd_message('AR_INAPI_NONUNIQUE_DESC_FLEX'),
                  'RA_INTERFACE_LINES') ;
            END IF;

            Validate_Line_Int_Flex(
                p_desc_flex_rec       => p_trx_line_int_attr_rec,
                p_desc_flex_name      => 'RA_INTERFACE_LINES',
                p_return_status       => x_return_status );
            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        trx_line_id,
                        error_message,
                        invalid_value) VALUES (
                 clFlexIntAttrRec.trx_header_id,
                 clFlexIntAttrRec.trx_line_id,
                  arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                  'RA_INTERFACE_LINES') ;
            END IF;
        END LOOP;
    ELSIF p_validation_type = 'DISTRIBUTIONS'
    THEN
        FOR cdFlexAttrRec IN cdFlexAttr
        LOOP
            p_trx_attr_rec.attribute_category := cdFlexAttrRec.attribute_category;
            p_trx_attr_rec.attribute1 := cdFlexAttrRec.attribute1;
            p_trx_attr_rec.attribute2 := cdFlexAttrRec.attribute2;
            p_trx_attr_rec.attribute3 := cdFlexAttrRec.attribute3;
            p_trx_attr_rec.attribute4 := cdFlexAttrRec.attribute4;
            p_trx_attr_rec.attribute5 := cdFlexAttrRec.attribute5;
            p_trx_attr_rec.attribute6 := cdFlexAttrRec.attribute6;
            p_trx_attr_rec.attribute7 := cdFlexAttrRec.attribute7;
            p_trx_attr_rec.attribute8 := cdFlexAttrRec.attribute8;
            p_trx_attr_rec.attribute9 := cdFlexAttrRec.attribute9;
            p_trx_attr_rec.attribute10 := cdFlexAttrRec.attribute10;
            p_trx_attr_rec.attribute11 := cdFlexAttrRec.attribute11;
            p_trx_attr_rec.attribute12 := cdFlexAttrRec.attribute12;
            p_trx_attr_rec.attribute13 := cdFlexAttrRec.attribute13;
            p_trx_attr_rec.attribute14 := cdFlexAttrRec.attribute14;
            p_trx_attr_rec.attribute15 := cdFlexAttrRec.attribute15;

            arp_util.Validate_Desc_Flexfield(
                p_desc_flex_rec       => p_trx_attr_rec,
                p_desc_flex_name      => 'RA_CUST_TRX_LINE_GL_DIST',
                p_return_status       => x_return_status );

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        trx_line_id,
                        trx_dist_id,
                        error_message,
                        invalid_value) values (
                    cdFlexAttrRec.trx_header_id,
                    cdFlexAttrRec.trx_line_id,
                    cdFlexAttrRec.trx_dist_id,
                    arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                    'RA_CUST_TRX_LINE_GL_DIST') ;
            END IF;
        END LOOP;
    ELSIF p_validation_type = 'SALESREPS'
    THEN
        FOR csFlexAttrRec IN csFlexAttr
        LOOP
            p_trx_attr_rec.attribute_category := csFlexAttrRec.attribute_category;
            p_trx_attr_rec.attribute1 := csFlexAttrRec.attribute1;
            p_trx_attr_rec.attribute2 := csFlexAttrRec.attribute2;
            p_trx_attr_rec.attribute3 := csFlexAttrRec.attribute3;
            p_trx_attr_rec.attribute4 := csFlexAttrRec.attribute4;
            p_trx_attr_rec.attribute5 := csFlexAttrRec.attribute5;
            p_trx_attr_rec.attribute6 := csFlexAttrRec.attribute6;
            p_trx_attr_rec.attribute7 := csFlexAttrRec.attribute7;
            p_trx_attr_rec.attribute8 := csFlexAttrRec.attribute8;
            p_trx_attr_rec.attribute9 := csFlexAttrRec.attribute9;
            p_trx_attr_rec.attribute10 := csFlexAttrRec.attribute10;
            p_trx_attr_rec.attribute11 := csFlexAttrRec.attribute11;
            p_trx_attr_rec.attribute12 := csFlexAttrRec.attribute12;
            p_trx_attr_rec.attribute13 := csFlexAttrRec.attribute13;
            p_trx_attr_rec.attribute14 := csFlexAttrRec.attribute14;
            p_trx_attr_rec.attribute15 := csFlexAttrRec.attribute15;

            arp_util.Validate_Desc_Flexfield(
                p_desc_flex_rec       => p_trx_attr_rec,
                p_desc_flex_name      => 'RA_CUST_TRX_LINE_SALESREPS',
                p_return_status       => x_return_status );

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS
            THEN
                INSERT INTO ar_trx_errors_gt
                    (   trx_header_id,
                        trx_line_id,
                        trx_salescredit_id,
                        error_message,
                        invalid_value) values (
                    csFlexAttrRec.trx_header_id,
                    csFlexAttrRec.trx_line_id,
                    csFlexAttrRec.trx_salescredit_id,
                    arp_standard.fnd_message('AR_INAPI_INVALID_DESC_FLEX'),
                    'RA_CUST_TRX_LINE_SALESREPS') ;
            END IF;
        END LOOP;
    END IF;  -- end of validation_level
    -- assign the status to success agin so that next validation
    -- can continue.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
END validate_desc_flex;


END AR_INVOICE_VALIDATE_FLEX;

/
