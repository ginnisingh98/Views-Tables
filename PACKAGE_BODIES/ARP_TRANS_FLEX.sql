--------------------------------------------------------
--  DDL for Package Body ARP_TRANS_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRANS_FLEX" AS
/* $Header: ARTUFLXB.pls 115.7 2002/11/18 22:56:06 anukumar ship $ */


TYPE flex_context_type IS TABLE OF
       fnd_descr_flex_contexts.descriptive_flex_context_code%type
            INDEX by binary_integer;

TYPE flex_num_type IS TABLE OF number INDEX by binary_integer;

TYPE seg_value_type IS TABLE OF
       ra_interface_lines.interface_line_attribute1%type
            INDEX by binary_integer;

TYPE cursor_tbl_type IS
       TABLE OF  BINARY_INTEGER
       INDEX BY  BINARY_INTEGER;

/*-------------------------------------------------------------------------+
 | Contexts  Num_Segs  Start_Loc                   Active Segments         |
 |                                                                         |
 | Ctx1      2         1                           1                       |
 |                                                 2                       |
 | Ctx2      1         3                           5                       |
 | Ctx3      0         3                                                   |
 +-------------------------------------------------------------------------*/
pg_flex_contexts flex_context_type;    --  flex context values
pg_ctl_cursors   cursor_tbl_type;      --  cursors for ra_customer_trx_lines
pg_ril_cursors   cursor_tbl_type;      --  cursors for ra_interface_lines
pg_active_segs   flex_num_type;        --  active segment numbers
pg_num_segs      flex_num_type;        --  number of segments for each context
pg_start_loc     flex_num_type;        --  for a context, index to first
                                       --  segment in pg_active_segs
pg_ctx_count     number;               --  total number of contexts


pg_char_dummy    varchar2(10) := '!#$%^&*';

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    setup_descr_flex                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Setup the flex cache. Gets the active contexts and segments for a      |
 |    descriptive flex                                                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_appl_id                                              |
 |                    p_desc_flex                                            |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |                                                                           |
 +===========================================================================*/

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

  arp_util.debug('arp_trans_flex.setup_descr_flex()+');

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

  arp_util.debug('arp_trans_flex.setup_descr_flex()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_trans_flex.setup_descr_flex()');
    arp_util.debug('p_appl_id      : '||p_appl_id);
    arp_util.debug('p_desc_flex    : '||p_desc_flex);

    RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    print_cache_contents                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Prints the contents of the cache. Used for debugging purposes          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None                                                   |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |                                                                           |
 +===========================================================================*/
PROCEDURE print_cache_contents
IS
  l_loc   number;
BEGIN

  arp_util.debug('arp_trans_flex.print_cache_contents()+');

  arp_util.debug('Number of contexts : '||to_char(pg_ctx_count));


  FOR i IN 1..pg_ctx_count LOOP

     arp_util.debug('Context : '||pg_flex_contexts(i)||
                    '   Segs : '||to_char(pg_num_segs(i))||
                    '  Start : '||to_char(pg_start_loc(i)));

     FOR j IN 1..pg_num_segs(i) LOOP

        l_loc := pg_start_loc(i) + j - 1;

        arp_util.debug('        '||pg_active_segs(l_loc));

     END LOOP;
  END LOOP;

  arp_util.debug('arp_trans_flex.print_cache_contents()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_trans_flex.print_cache_contents()');
    RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    find_context                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Search for the context in the cache and return its location in the     |
 |    cache table                                                            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_context                                              |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NUMBER index to cache table                                  |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |                                                                           |
 +===========================================================================*/

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
    arp_util.debug('EXCEPTION : arp_trans_flex.find_context()');
    arp_util.debug('p_context      : '||p_context);

    RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    build_where_clause                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Constructs the where clause based on the context and the descr. flex   |
 |    values                                                                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_context                                              |
 |		      p_context_index					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    p_where_clause                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |    The WHERE clause is constructed as follows                             |
 |                                                                           |
 |    If the value of the attribute parameter that corresponds to a segment  |
 |    is NULL then                                                           |
 |        INTERFACE_LINE_ATTRIBUTE<seg_num> IS NULL                          |
 |                                                                           |
 |    Otherwise                                                              |
 |        INTERFACE_LINE_ATTRIBUTE<seg_num> = <value passed>                 |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |      11-FEB-97  Charlie Tomberg     Modified to keep cursors open.        |
 |                                                                           |
 +===========================================================================*/

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

   arp_util.debug('arp_trans_flex.build_where_clause()+');

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
          arp_util.debug('AR', 'AR_INV_TRANS_FLEX_CONTEXT');
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

   -- arp_util.debug('Where clause : '||p_where_clause);

   arp_util.debug('arp_trans_flex.build_where_clause()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_trans_flex.build_where_clause');
    arp_util.debug('p_context      : '||p_context);

    RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_uniqueness                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Check for the uniqueness of the transaction flex in the specified      |
 |    table                                                                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.open_cursor                                                   |
 |    dbms_sql.close_cursor                                                  |
 |    dbms_sql.parse                                                         |
 |    dbms_sql.execute_and_fetch                                             |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cursor                                               |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                 TRUE : If no matching rows are found i.e flex is unique   |
 |                 FALSE: If atleast one matching row is found               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |      11-FEB-97  Charlie Tomberg     Modified to keep cursors open.        |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_uniqueness(
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

   arp_util.debug('arp_trans_flex.check_uniqueness()+');

   dbms_sql.define_column( p_cursor, 1, l_customer_trx_id);
   dbms_sql.define_column( p_cursor, 2, l_customer_trx_line_id);

   l_dummy := dbms_sql.execute(p_cursor);
   l_rows  := dbms_sql.fetch_rows(p_cursor);


  /*-------------------------------------------------------------+
   | If any matching rows are found then the flex is non-unique, |
   | return FALSE. Otherwise return TRUE                         |
   +-------------------------------------------------------------*/

   IF (l_rows > 0)
   THEN
       dbms_sql.column_value( p_cursor, 1, l_customer_trx_id);
       dbms_sql.column_value( p_cursor, 2, l_customer_trx_line_id);
       p_customer_trx_id      := l_customer_trx_id;
       p_customer_trx_line_id := l_customer_trx_line_id;

       arp_util.debug('arp_trans_flex.check_uniqueness()-');
       return(FALSE);
   END IF;

   arp_util.debug('arp_trans_flex.check_uniqueness()-');
   return(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_trans_flex.check_uniqueness()');
    arp_util.debug('p_cursor     : '|| p_cursor);

    IF (p_cursor IS NOT NULL)
    THEN dbms_sql.close_cursor(p_cursor);
    END IF;

    RAISE;
END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_Cursor                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Builds and parses the SQL statement that checks for uniquness for a    |
 |    given table and context and returns the cursor number.                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_context_index					     |
 |                    p_table_name					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      11-FEB-97  Charlie Tomberg     Created                               |
 |      10-APR-01  YREDDY              Bug 1677311: Added condition so that  |
 |                                     uniqueness will be tested against only|
 |                                     the unposted records in interface     |
 |                                     table.                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_Cursor(
                      p_context_index   IN BINARY_INTEGER,
                      p_table_name      IN VARCHAR2
                    ) RETURN  BINARY_INTEGER  IS

   l_context       ra_customer_trx_lines.interface_line_context%type;
   l_stmt	   VARCHAR2(2000);
   l_where_clause  VARCHAR2(2000);
   l_cursor        BINARY_INTEGER;

BEGIN

   arp_util.debug('arp_trans_flex.Get_Cursor()+');

   l_context := pg_flex_contexts( p_context_index );

  /*-----------------------------+
   | construct the WHERE clause  |
   +-----------------------------*/
   build_where_clause( l_context,
                       p_context_index,
                       l_where_clause);


   IF (p_table_name = 'RA_INTERFACE_LINES')
   THEN   l_stmt := 'SELECT 0, 0 FROM '|| p_table_name;
   ELSE   l_stmt := 'SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID FROM '||
          p_table_name;
   END IF;

   IF (l_where_clause IS NOT NULL)
   THEN
     /*----------------------------------------------------------------+
      |  Construct additional WHERE clause based on the table that is  |
      |  being checked.                                                |
      |  For RA_INTERFACE_LINES, the context is always filled in even  |
      |  if it is a Global context and for RA_CUSTOMER_TRX_LINES the   |
      |  context is NULL if it is a Global context. Also, do not       |
      |  include the current row when checking the uniqueness of the   |
      |  transaction flex in RA_CUSTOMER_TRX_LINES                     |
      +----------------------------------------------------------------*/
/* Bug 1677311: Added condition interface status <> 'P' */

      IF (p_table_name = 'RA_INTERFACE_LINES')
      THEN
          l_stmt := l_stmt||' WHERE interface_line_context = '''||
                    nvl(l_context, 'Global Data Elements')||'''';
          l_stmt := l_stmt||' AND  NVL(interface_status,''~'') <> ''P''';
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

   arp_util.debug('SQL Stmt : '||l_stmt);

  /*---------------------------------------------------+
   | Open, Parse and Execute the constructed SQL stmt  |
   +---------------------------------------------------*/

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_stmt, dbms_sql.v7);

   IF    (p_table_name = 'RA_CUSTOMER_TRX_LINES')
   THEN  pg_ctl_cursors( p_context_index ) := l_cursor;
   ELSE  pg_ril_cursors( p_context_index ) := l_cursor;
   END IF;

   arp_util.debug('arp_trans_flex.Get_Cursor()-');

   RETURN(l_cursor);

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_trans_flex.Get_Cursor()');
    arp_util.debug('p_context_index  = ' || TO_CHAR( p_context_index));
    arp_util.debug('p_table_name     = ' || p_table_name);

    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Bind_Variable                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds a single variable to the specified cursor.                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_bind_variable					     |
 |                    p_value         					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |      This routine traps the 1006 'Bind Variable Does Not Exist' error and |
 |      ignores it since not all columns will be used with a given context.  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      11-FEB-97  Charlie Tomberg     Created                               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Bind_Variable(   p_cursor         IN INTEGER,
                           p_bind_variable  IN VARCHAR2,
                           p_value          IN VARCHAR2
                       ) IS
BEGIN

          arp_util.debug('arp_trans_flex.Bind_Variables()+');

          dbms_sql.bind_variable( p_cursor,
                                  p_bind_variable,
                                  p_value );

          arp_util.debug('arp_trans_flex.Bind_Variables()-');

EXCEPTION
      WHEN OTHERS THEN
          IF (SQLCODE = -1006)
          THEN NULL;
          ELSE
                arp_util.debug('EXCEPTION : arp_trans_flex.Bind_Variable()');
                arp_util.debug('p_cursor         = ' || p_cursor);
                arp_util.debug('p_bind_variable  = ' || p_bind_variable);
                arp_util.debug('p_value          = ' || p_value);

                RAISE;
          END IF;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Bind_All_Variables                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds a all of the columns that might be referenced in the SQL         |
 |    statements to their appropriate cursors.                               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_line_id				     |
 |                  p_interface_line_context				     |
 |                  p_interface_line_attribute1				     |
 |                  p_interface_line_attribute2				     |
 |                  p_interface_line_attribute3				     |
 |                  p_interface_line_attribute4				     |
 |                  p_interface_line_attribute5				     |
 |                  p_interface_line_attribute6				     |
 |                  p_interface_line_attribute7				     |
 |                  p_interface_line_attribute8				     |
 |                  p_interface_line_attribute9				     |
 |                  p_interface_line_attribute10			     |
 |                  p_interface_line_attribute11			     |
 |                  p_interface_line_attribute12			     |
 |                  p_interface_line_attribute13			     |
 |                  p_interface_line_attribute14			     |
 |                  p_interface_line_attribute15			     |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                  p_ctl_cursor					     |
 |                  p_ril_cursor					     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      11-FEB-97  Charlie Tomberg     Created                               |
 |                                                                           |
 +===========================================================================*/

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

     arp_util.debug('arp_trans_flex.Bind_All_Variables()+');


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
             arp_util.debug('Handling INVALID_CURSOR exception by reparsing');

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
    |  Bind variables into the ra_interface_lines cursor  |
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
             arp_util.debug('Handling INVALID_CURSOR exception by reparsing');

             p_ril_cursor := Get_Cursor(
                                         p_context_index,
                                         'RA_INTERFACE_LINES'
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

     arp_util.debug('arp_trans_flex.Bind_All_Variables()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_trans_flex.Bind_All_Variables');

    arp_util.debug('p_ctl_cursor                  : ' || p_ctl_cursor);
    arp_util.debug('p_ril_cursor                  : ' || p_ctl_cursor);
    arp_util.debug('p_customer_trx_line_id        : '||p_customer_trx_line_id);
    arp_util.debug('p_interface_line_context      : '||
                                         p_interface_line_context);
    arp_util.debug('p_interface_line_attribute2   : '||
                                         p_interface_line_attribute2);
    arp_util.debug('p_interface_line_attribute3   : '||
                                         p_interface_line_attribute3);
    arp_util.debug('p_interface_line_attribute4   : '||
                                         p_interface_line_attribute4);
    arp_util.debug('p_interface_line_attribute5   : '||
                                         p_interface_line_attribute5);
    arp_util.debug('p_interface_line_attribute6   : '||
                                         p_interface_line_attribute6);
    arp_util.debug('p_interface_line_attribute7   : '||
                                         p_interface_line_attribute7);
    arp_util.debug('p_interface_line_attribute8   : '||
                                         p_interface_line_attribute8);
    arp_util.debug('p_interface_line_attribute9   : '||
                                         p_interface_line_attribute9);
    arp_util.debug('p_interface_line_attribute10  : '||
                                         p_interface_line_attribute10);
    arp_util.debug('p_interface_line_attribute11  : '||
                                         p_interface_line_attribute11);
    arp_util.debug('p_interface_line_attribute12  : '||
                                         p_interface_line_attribute12);
    arp_util.debug('p_interface_line_attribute13  : '||
                                         p_interface_line_attribute13);
    arp_util.debug('p_interface_line_attribute14  : '||
                                         p_interface_line_attribute14);
    arp_util.debug('p_interface_line_attribute15  : '||
                                         p_interface_line_attribute15);

    RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    unique_trans_flex                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validates the transaction flexfield                                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ctl_id                                               |
 |                    p_interface_line_context                               |
 |                    p_interface_line_attribute1                            |
 |                    p_interface_line_attribute2                            |
 |                    p_interface_line_attribute3                            |
 |                    p_interface_line_attribute4                            |
 |                    p_interface_line_attribute5                            |
 |                    p_interface_line_attribute6                            |
 |                    p_interface_line_attribute7                            |
 |                    p_interface_line_attribute8                            |
 |                    p_interface_line_attribute9                            |
 |                    p_interface_line_attribute10                           |
 |                    p_interface_line_attribute11                           |
 |                    p_interface_line_attribute12                           |
 |                    p_interface_line_attribute13                           |
 |                    p_interface_line_attribute14                           |
 |                    p_interface_line_attribute15                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                 TRUE : If the transaction flex is UNIQUE                  |
 |                 FALSE: If the transaction flex is NOT UNIQUE              |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      24-OCT-95  Subash Chadalavada  Created                               |
 |      11-FEB-97  Charlie Tomberg     Modified to keep cursors open.        |
 |                                                                           |
 +===========================================================================*/

FUNCTION unique_trans_flex(
  p_ctl_id                    IN
                    ra_customer_trx_lines.customer_trx_line_id%type,
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
                    ra_customer_trx_lines.interface_line_attribute15%type,
  p_customer_trx_id            OUT NOCOPY ra_customer_trx.customer_trx_id%type,
  p_customer_trx_line_id       OUT NOCOPY
                    ra_customer_trx_lines.customer_trx_line_id%type)
RETURN boolean IS

  l_seg_value      seg_value_type;
  l_where_clause   varchar2(1000);
  l_ctl_cursor     BINARY_INTEGER;
  l_ril_cursor     BINARY_INTEGER;
  l_context_index  BINARY_INTEGER;
  l_dummy          BINARY_INTEGER;

BEGIN

   arp_util.debug('arp_trans_flex.unique_trans_flex()+');

  /*------------------------------------------------+
   |  Get the context index from the context cache  |
   +------------------------------------------------*/

   l_context_index := Find_Context(
                                    nvl(p_interface_line_context,
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
           THEN l_ctl_cursor := Get_Cursor(
                                             l_context_index,
                                             'RA_CUSTOMER_TRX_LINES'
                                          );
      WHEN OTHERS THEN RAISE;
   END;


   BEGIN
      l_ril_cursor := pg_ril_cursors( l_context_index );
   EXCEPTION
      WHEN NO_DATA_FOUND
           THEN l_ril_cursor := Get_Cursor(
                                             l_context_index,
                                             'RA_INTERFACE_LINES' );

      WHEN OTHERS THEN RAISE;
   END;

   Bind_All_Variables(
                       l_ctl_cursor,
                       l_ril_cursor,
                       l_context_index,
                       p_ctl_id,
                       p_interface_line_context,
                       p_interface_line_attribute1,
                       p_interface_line_attribute2,
                       p_interface_line_attribute3,
                       p_interface_line_attribute4,
                       p_interface_line_attribute5,
                       p_interface_line_attribute6,
                       p_interface_line_attribute7,
                       p_interface_line_attribute8,
                       p_interface_line_attribute9,
                       p_interface_line_attribute10,
                       p_interface_line_attribute11,
                       p_interface_line_attribute12,
                       p_interface_line_attribute13,
                       p_interface_line_attribute14,
                       p_interface_line_attribute15
                    );

  /*----------------------------------------------------------------------+
   | check for the uniqueness of the flex in RA_CUSTOMER_TRX_LINES table  |
   +----------------------------------------------------------------------*/
   IF (NOT check_uniqueness(
                             l_ctl_cursor,
                             p_customer_trx_id,
                             p_customer_trx_line_id
                           ) )
   THEN
       return(FALSE);
   END IF;

  /*----------------------------------------------------------------------+
   | check for the uniqueness of the flex in RA_INTERFACE_LINES    table  |
   +----------------------------------------------------------------------*/
   IF (NOT check_uniqueness(
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
    arp_util.debug('EXCEPTION : arp_trans_flex.unique_trans_flex');

    arp_util.debug('p_ctl_id                      : '|| p_ctl_id);
    arp_util.debug('p_interface_line_context      : '||
                                         p_interface_line_context);
    arp_util.debug('p_interface_line_attribute2   : '||
                                         p_interface_line_attribute2);
    arp_util.debug('p_interface_line_attribute3   : '||
                                         p_interface_line_attribute3);
    arp_util.debug('p_interface_line_attribute4   : '||
                                         p_interface_line_attribute4);
    arp_util.debug('p_interface_line_attribute5   : '||
                                         p_interface_line_attribute5);
    arp_util.debug('p_interface_line_attribute6   : '||
                                         p_interface_line_attribute6);
    arp_util.debug('p_interface_line_attribute7   : '||
                                         p_interface_line_attribute7);
    arp_util.debug('p_interface_line_attribute8   : '||
                                         p_interface_line_attribute8);
    arp_util.debug('p_interface_line_attribute9   : '||
                                         p_interface_line_attribute9);
    arp_util.debug('p_interface_line_attribute10  : '||
                                         p_interface_line_attribute10);
    arp_util.debug('p_interface_line_attribute11  : '||
                                         p_interface_line_attribute11);
    arp_util.debug('p_interface_line_attribute12  : '||
                                         p_interface_line_attribute12);
    arp_util.debug('p_interface_line_attribute13  : '||
                                         p_interface_line_attribute13);
    arp_util.debug('p_interface_line_attribute14  : '||
                                         p_interface_line_attribute14);
    arp_util.debug('p_interface_line_attribute15  : '||
                                         p_interface_line_attribute15);

    RAISE;
END;

FUNCTION  unique_trans_flex(
  p_ctl_id                    IN
                    ra_customer_trx_lines.customer_trx_line_id%type,
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
                    ra_customer_trx_lines.interface_line_attribute15%type)
RETURN BOOLEAN IS

  l_dummy  BINARY_INTEGER;

BEGIN
      RETURN(
              unique_trans_flex(
                                 p_ctl_id,
                                 p_interface_line_context,
                                 p_interface_line_attribute1,
                                 p_interface_line_attribute2,
                                 p_interface_line_attribute3,
                                 p_interface_line_attribute4,
                                 p_interface_line_attribute5,
                                 p_interface_line_attribute6,
                                 p_interface_line_attribute7,
                                 p_interface_line_attribute8,
                                 p_interface_line_attribute9,
                                 p_interface_line_attribute10,
                                 p_interface_line_attribute11,
                                 p_interface_line_attribute12,
                                 p_interface_line_attribute13,
                                 p_interface_line_attribute14,
                                 p_interface_line_attribute15,
                                 l_dummy,
                                 l_dummy
                                )
             );

END;

BEGIN

 /*-----------------------------------------------------------------------+
  | initialization section. Initialize the package PL/SQL variables with  |
  | the transaction flex information                                      |
  +-----------------------------------------------------------------------*/
  setup_descr_flex(222, 'RA_INTERFACE_LINES');

END;

/
