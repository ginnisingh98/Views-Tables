--------------------------------------------------------
--  DDL for Package Body PO_PERIODS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PERIODS_SV" as
-- $Header: POXCOPEB.pls 120.0.12010000.6 2014/06/10 04:39:56 rkandima ship $




-----------------------------------------------------------------------------
-- Declare private package types.
-----------------------------------------------------------------------------

/* Bug 3292931: A table of ROWID is not allowed in an 8i database.  Instead,
 * use a table of VARCHAR2 and use the ROWIDTOCHAR() and CHARTOROWID() functions.
 * A ROWID is compatible with a VARCHAR2 of size 18.
 */

--TYPE g_tbl_rowid IS TABLE OF ROWID;
TYPE g_tbl_rowid IS TABLE OF VARCHAR2(18);




-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------

-- Debugging

g_pkg_name                       CONSTANT
   VARCHAR2(30)
   := 'PO_PERIODS_SV'
   ;
g_log_head                       CONSTANT
   VARCHAR2(50)
   := 'po.plsql.' || g_pkg_name || '.'
   ;

g_debug_stmt
   BOOLEAN
   ;
g_debug_unexp
   BOOLEAN
   ;




-----------------------------------------------------------------------------
-- Define procedures.
-----------------------------------------------------------------------------




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_period_info
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the GL period info for the given dates.
--  Period information will only be found if
--  the date falls within a usable period (valid for both GL and PO).
--  If a usable period is not found for any of the given dates,
--  the x_invalid_period_flag will be FND_API.g_TRUE,
--  and the other out parameters corresponding to the date will be NULL.
--Parameters:
--IN:
--p_roll_logic
--  Intended to be flexible to use roll-forward/roll-backward logic
--  for encumbrance.  Currently not supported.
--  Use NULL.
--p_set_of_books_id
--  If the set of books is not passed, it will be derived from
--  FINANCIALS_SYSTEM_PARAMETERS.
--p_date_tbl
--  Dates of which to find the periods.
--OUT:
--  These correspond to the dates in p_date_tbl.
--x_period_name_tbl
--x_period_year_tbl
--x_period_num_tbl
--x_quarter_num_tbl
--
--x_invalid_period_flag
--  Indicates whether or not usable periods were found for each of the
--  given dates.
--    FND_API.g_TRUE    a usable period was not found for at least one date
--    FND_API.g_FALSE   usable periods were found for each date
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_period_info(
   p_roll_logic                     IN             VARCHAR2
,  p_set_of_books_id                IN             NUMBER
,  p_date_tbl                       IN             po_tbl_date
,  x_period_name_tbl                OUT NOCOPY     po_tbl_varchar30
,  x_period_year_tbl                OUT NOCOPY     po_tbl_number
,  x_period_num_tbl                 OUT NOCOPY     po_tbl_number
,  x_quarter_num_tbl                OUT NOCOPY     po_tbl_number
,  x_invalid_period_flag            OUT NOCOPY     VARCHAR2
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_PERIOD_INFO';
l_progress     VARCHAR2(3) := '000';

l_set_of_books_id    NUMBER;

l_date_key  NUMBER;
l_rowid_tbl g_tbl_rowid;

l_no_dates_exc    EXCEPTION;

-- bug 5498063 <R12 GL PERIOD VALIDATION>
l_validate_gl_period VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_roll_logic', p_roll_logic);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_set_of_books_id', p_set_of_books_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_date_tbl', p_date_tbl);
END IF;

l_progress := '010';

IF (p_date_tbl IS NULL) THEN
   RAISE l_no_dates_exc;
ELSIF (p_date_tbl.COUNT = 0) THEN
   RAISE l_no_dates_exc;
END IF;

l_progress := '015';

-- Get the set of books id.

IF (p_set_of_books_id IS NULL) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'set of books is NULL');
   END IF;

   SELECT FSP.set_of_books_id
   INTO l_set_of_books_id
   FROM FINANCIALS_SYSTEM_PARAMETERS FSP
   ;

   l_progress := '030';

ELSE

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'set of books passed');
   END IF;

   l_set_of_books_id := p_set_of_books_id;

   l_progress := '050';

END IF;

l_progress := '060';

-- Use the scratchpad to avoid PL/SQL limitations.

SELECT PO_SESSION_GT_S.nextval
INTO l_date_key
FROM DUAL
;

l_progress := '070';

-----------------------------------------
-- PO_SESSION_GT column mapping
--
-- date1    GL date
-- char1    period_name
-- num1     period_year
-- num2     period_num
-- num3     quarter_num
-----------------------------------------

/* Bug 3292931: A table of ROWID is not allowed in an 8i database.  Instead,
 * use a table of VARCHAR2 and use the ROWIDTOCHAR() and CHARTOROWID() functions.
 */

FORALL i IN 1 .. p_date_tbl.COUNT
INSERT INTO PO_SESSION_GT ( key, date1 )
VALUES ( l_date_key, p_date_tbl(i) )
RETURNING ROWIDTOCHAR(rowid)
BULK COLLECT INTO l_rowid_tbl
;

l_progress := '080';

/* Bug 3292931: A table of ROWID is not allowed in an 8i database.  Instead,
 * use a table of VARCHAR2 and use the ROWIDTOCHAR() and CHARTOROWID() functions.
 * Changes made below to how l_rowid_tbl is interpreted.
 */

-- bug 5206339 <11.5.10 GL PERIOD VALIDATION>
l_validate_gl_period := nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y');

FORALL i IN 1 .. l_rowid_tbl.COUNT
UPDATE PO_SESSION_GT SES
SET
(  char1    -- period_name
,  num1     -- period_year
,  num2     -- period_num
,  num3     -- quarter_num
)
=
(  SELECT
      GL_PS.period_name
   ,  GL_PS.period_year
   ,  GL_PS.period_num
   ,  GL_PS.quarter_num
   FROM
      GL_PERIOD_STATUSES GL_PS
   ,  GL_PERIOD_STATUSES PO_PS
   ,  GL_SETS_OF_BOOKS SOB
   WHERE SOB.set_of_books_id = l_set_of_books_id
   AND   GL_PS.application_id = 101
   AND   PO_PS.application_id = 201
   AND   GL_PS.set_of_books_id = SOB.set_of_books_id  --JOIN
   AND   PO_PS.set_of_books_id = SOB.set_of_books_id  --JOIN
   AND   GL_PS.period_name = PO_PS.period_name        --JOIN
   -- GL period conditions
   -- bug 5498063 <R12 GL PERIOD VALIDATION>
   --   AND   GL_PS.closing_status IN ('O','F')   open or future-enterable
    AND ((l_validate_gl_period IN ('Y','R') --14178037 <GL DATE Project>
        and GL_PS.closing_status IN ('O', 'F'))
     OR
        (l_validate_gl_period = 'N'))
   -- bug 5498063 <R12 GL PERIOD VALIDATION>
   AND   GL_PS.adjustment_period_flag = 'N'  -- not an adjusting period
   AND   GL_PS.period_year <= SOB.latest_encumbrance_year
   -- PO period conditions
   AND   PO_PS.closing_status = 'O'          -- open
   AND   PO_PS.adjustment_period_flag = 'N'  -- not an adjusting period
   -- Date logic (to include roll-forward, roll-backward?)
   -- See PO_ENCUMBRANCE_PREPROCESSING.find_open_period
   AND   TRUNC(SES.date1)
            BETWEEN TRUNC(GL_PS.start_date) AND TRUNC(GL_PS.end_date)
)
WHERE SES.rowid = CHARTOROWID(l_rowid_tbl(i))
RETURNING
   SES.char1    -- period_name
,  SES.num1     -- period_year
,  SES.num2     -- period_num
,  SES.num3     -- quarter_num
BULK COLLECT INTO
   x_period_name_tbl
,  x_period_year_tbl
,  x_period_num_tbl
,  x_quarter_num_tbl
;

l_progress := '100';

-- Figure out if any periods were not found.

x_invalid_period_flag := FND_API.G_FALSE;

BEGIN

   l_progress := '110';

   SELECT FND_API.G_TRUE
   INTO x_invalid_period_flag
   FROM PO_SESSION_GT SES
   WHERE SES.key = l_date_key
   AND SES.char1 IS NULL
   AND rownum = 1
   ;

   l_progress := '120';

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      l_progress := '130';
END;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_invalid_period_flag',x_invalid_period_flag);
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_name_tbl', x_period_name_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_year_tbl', x_period_year_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_num_tbl', x_period_num_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_quarter_num_tbl', x_quarter_num_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_invalid_period_flag',x_invalid_period_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION

WHEN l_no_dates_exc THEN
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'l_no_dates_exc: Empty date table.');
   END IF;

   l_progress := '910';

   x_period_name_tbl := po_tbl_varchar30();
   x_period_year_tbl := po_tbl_number();
   x_period_num_tbl := po_tbl_number();
   x_quarter_num_tbl := po_tbl_number();
   x_invalid_period_flag := FND_API.g_FALSE;

   l_progress := '912';

   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_name_tbl', x_period_name_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_year_tbl', x_period_year_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_period_num_tbl', x_period_num_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_quarter_num_tbl', x_quarter_num_tbl);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_invalid_period_flag',x_invalid_period_flag);
      PO_DEBUG.debug_end(l_log_head);
   END IF;

WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_period_info;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_period_name
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the GL period name for the given date,
--  if the date is in a usable period (valid for GL and PO).
--Parameters:
--IN:
--x_sob_id
--  Set of books.
--x_gl_date
--  Date for which to find the period name.
--OUT:
--x_gl_period
--  The period name corresponding to the given date.
--Notes:
--  This procedure was refactored in FPJ to call the more generalized
--  procedure get_period_info.  However, the parameter names were
--  not changed to meet standards, as that may have impacted calling code.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_period_name(
   x_sob_id                         IN             NUMBER
,  x_gl_date                        IN             DATE
,  x_gl_period                      OUT NOCOPY     VARCHAR2
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_PERIOD_NAME';
l_progress     VARCHAR2(3) := '000';

l_period_name_tbl       po_tbl_varchar30;
l_period_year_tbl       po_tbl_number;
l_period_num_tbl        po_tbl_number;
l_quarter_num_tbl       po_tbl_number;
l_invalid_period_flag   VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_sob_id',x_sob_id);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_gl_date',x_gl_date);
END IF;

l_progress := '010';

get_period_info(
   p_roll_logic => NULL
,  p_set_of_books_id => x_sob_id
,  p_date_tbl => po_tbl_date( x_gl_date )
,  x_period_name_tbl => l_period_name_tbl
,  x_period_year_tbl => l_period_year_tbl
,  x_period_num_tbl => l_period_num_tbl
,  x_quarter_num_tbl => l_quarter_num_tbl
,  x_invalid_period_flag => l_invalid_period_flag
);

l_progress := '020';

x_gl_period := l_period_name_tbl(1);

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_gl_period',x_gl_period);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_period_name;

 -------------------------------------------------------------------------------
     --14178037 <GL DATE Project Start>
     --Start of Comments
     --Name: build_GL_Encumbered_Date
     --Pre-reqs:
     --  None.
     --Modifies:
     --  None.
     --Locks:
     --  None.
     --Function:
     --  Derive proper GL date, when the profile PO: Validate GL Period has been
     --  set to Redefault.
     --  1st preference need to be given to the GL date that has been passed (i.e.
     --  GL  date at the distribution level.
     --  2nd preference need to be given to the System date.
     --  3rd preference need to be given to the earliest open period.
     --Parameters:
     --IN:
     --l_sob_id
     --  Set of books.
     --IN OUT:
     --  x_gl_date
     --  Date, which needs to be replaced with a correct date, if not open.
     -- OUT:
     --  x_gl_period
     --  Period, derived based on the GL date derived.
     --Notes:
     --  This procedure was written for GL Date (CLM Phase 2) project.
     --  The requirement is to derive a Latest Open Period's GL Date, if the
     --  entered/present GL date is not in Open period.
     --Testing:
     --
     --End of Comments
     -------------------------------------------------------------------------------
     PROCEDURE build_GL_Encumbered_Date(l_sob_id    IN NUMBER,
                                        x_gl_date   IN OUT NOCOPY DATE,
                                        x_gl_period OUT NOCOPY VARCHAR2)

      IS
       d_mod      CONSTANT VARCHAR2(100) := 'D_build_gl_encumbered_date';
       l_log_head CONSTANT VARCHAR2(100) := g_log_head ||
                                            'build_GL_Encumbered_Date';
        l_validate_gl_period VARCHAR2(1) := nvl(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),
                                   'Y');

     Begin

       IF PO_LOG.d_proc THEN
         PO_LOG.proc_begin(d_mod, 'l_sob_id', l_sob_id);
         PO_LOG.proc_begin(d_mod, 'x_gl_date', x_gl_date);
         PO_LOG.proc_begin(d_mod, 'x_gl_period', x_gl_period);
       END IF;

-- bug 18780564

   IF (l_validate_gl_period = 'R' AND x_gl_date IS NULL ) THEN
        x_gl_date := sysdate;
   END IF;


       begin
         -- 1st Check: Find out whether passed GL date (distribution level) belongs
         --            to Open Period or not.
         SELECT GL_PS.period_name
           into x_gl_period
           FROM GL_PERIOD_STATUSES GL_PS,
                GL_PERIOD_STATUSES PO_PS,
                GL_SETS_OF_BOOKS   SOB
          WHERE SOB.set_of_books_id = l_sob_id
            AND GL_PS.application_id = 101
            AND PO_PS.application_id = 201
            AND GL_PS.set_of_books_id = SOB.set_of_books_id --JOIN
            AND PO_PS.set_of_books_id = SOB.set_of_books_id --JOIN
            AND GL_PS.period_name = PO_PS.period_name --JOIN
            AND ((l_validate_gl_period IN ('Y','R')
            AND GL_PS.closing_status IN ('O', 'F')) OR (l_validate_gl_period = 'N'))
            AND GL_PS.adjustment_period_flag = 'N' -- not an adjusting period
            AND GL_PS.period_year <= SOB.latest_encumbrance_year
            AND PO_PS.closing_status = 'O' -- open
            AND PO_PS.adjustment_period_flag = 'N' -- not an adjusting period
            AND TRUNC(Nvl(x_gl_date, SYSDATE)) BETWEEN TRUNC(GL_PS.start_date) AND
                TRUNC(GL_PS.end_date)
            and rownum = 1;

       exception
         when no_data_found THEN
           -- No Data found means the passed GL Date is not in an open period
           BEGIN
             -- 2nd Check: Find out whether System date belongs to Open Period or not.
             SELECT GL_PS.period_name
               into x_gl_period
               FROM GL_PERIOD_STATUSES GL_PS,
                    GL_PERIOD_STATUSES PO_PS,
                    GL_SETS_OF_BOOKS   SOB
              WHERE SOB.set_of_books_id = l_sob_id
                AND GL_PS.application_id = 101
                AND PO_PS.application_id = 201
                AND GL_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                AND PO_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                AND GL_PS.period_name = PO_PS.period_name --JOIN
                AND ((l_validate_gl_period IN ('Y','R')
                AND GL_PS.closing_status IN ('O', 'F')) OR (l_validate_gl_period = 'N'))
                AND GL_PS.adjustment_period_flag = 'N' -- not an adjusting period
                AND GL_PS.period_year <= SOB.latest_encumbrance_year
                AND PO_PS.closing_status = 'O' -- open
                AND PO_PS.adjustment_period_flag = 'N' -- not an adjusting period
                AND TRUNC(sysdate) BETWEEN TRUNC(GL_PS.start_date) AND
                    TRUNC(GL_PS.end_date)
                and rownum = 1;

             x_gl_date := sysdate;

             IF po_log.d_proc THEN
               PO_LOG.proc_begin(l_log_head, 'x_gl_date', x_gl_date);
               PO_LOG.proc_begin(l_log_head, 'x_gl_period', x_gl_period);
             END IF;

           exception
           /* Bug14523678 past and future periods are not validated.
	      If user entered GLdate is not valid, sysdate is checked and even
	      if its closed,error is thrown.
	      when no_data_found then
               -- No Data found means Sysdate is not in an open period
               BEGIN
                 -- 3rd Check: Find out the Earliest Open Period date, which
                 --            falls in near Future period.
                 SELECT latest_period_name, latest_open_date
                   into x_gl_period, x_gl_date
                   FROM (

                         SELECT GL_PS.period_year,
                                 GL_PS.period_num,
                                 GL_PS.quarter_num,
                                 gl_ps.period_name latest_period_name,
                                 TRUNC(GL_PS.start_date) latest_open_date
                           FROM GL_PERIOD_STATUSES GL_PS,
                                 GL_PERIOD_STATUSES PO_PS,
                                 GL_SETS_OF_BOOKS   SOB
                          WHERE SOB.set_of_books_id = l_sob_id
                            AND GL_PS.application_id = 101
                            AND PO_PS.application_id = 201
                            AND GL_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                            AND PO_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                            AND GL_PS.period_name = PO_PS.period_name --JOIN
							AND ((l_validate_gl_period IN ('Y','R')
                            AND GL_PS.closing_status IN ('O', 'F')) OR (l_validate_gl_period = 'N'))
                            AND GL_PS.adjustment_period_flag = 'N' -- not an adjusting period
                            AND GL_PS.period_year <= SOB.latest_encumbrance_year
                            AND PO_PS.closing_status = 'O' -- open
                            AND PO_PS.adjustment_period_flag = 'N' -- not an adjusting period
                            AND TRUNC(GL_PS.start_date) >=
                                Trunc(Nvl(x_gl_date, SYSDATE))
                          ORDER BY GL_PS.period_year ASC,
                                    GL_PS.period_num  ASC,
                                    GL_PS.quarter_num ASC)
                  where ROWNUM = 1;
                 -- Call custom hook to get the Ct's preferred GL Date.
                 PO_CUSTOM_FUNDS_PKG.gl_date(x_gl_date, x_gl_period);

                 IF po_log.d_proc THEN
                   PO_LOG.proc_begin(l_log_head, 'x_gl_date', x_gl_date);
                   PO_LOG.proc_begin(l_log_head, 'x_gl_period', x_gl_period);
                 END IF;

                 -- Call custom hook to get the Ct's preferred GL Date.
                 PO_CUSTOM_FUNDS_PKG.gl_date(x_gl_date, x_gl_period);
               exception
                 when no_data_found then
                   -- No Data found means there exists no Earliest Open Period date,
                   -- which falls in near Future period.
                   BEGIN
                     -- 4th Check: Find out the Earliest Open Period date, which
                     --            falls in near Past period.
                     SELECT latest_period_name, latest_open_date
                       into x_gl_period, x_gl_date
                       FROM (

                             SELECT GL_PS.period_year,
                                     GL_PS.period_num,
                                     GL_PS.quarter_num,
                                     gl_ps.period_name latest_period_name,
                                     TRUNC(GL_PS.start_date) latest_open_date
                               FROM GL_PERIOD_STATUSES GL_PS,
                                     GL_PERIOD_STATUSES PO_PS,
                                     GL_SETS_OF_BOOKS   SOB
                              WHERE SOB.set_of_books_id = l_sob_id
                                AND GL_PS.application_id = 101
                                AND PO_PS.application_id = 201
                                AND GL_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                                AND PO_PS.set_of_books_id = SOB.set_of_books_id --JOIN
                                AND GL_PS.period_name = PO_PS.period_name --JOIN
								AND ((l_validate_gl_period IN ('Y','R')
                            AND GL_PS.closing_status IN ('O', 'F')) OR (l_validate_gl_period = 'N'))
                                AND GL_PS.adjustment_period_flag = 'N' -- not an adjusting period
                                AND GL_PS.period_year <=
                                    SOB.latest_encumbrance_year
                                AND PO_PS.closing_status = 'O' -- open
                                AND PO_PS.adjustment_period_flag = 'N' -- not an adjusting period
                                AND TRUNC(GL_PS.start_date) <
                                    Trunc(Nvl(x_gl_date, SYSDATE))
                              ORDER BY GL_PS.period_year desc,
                                        GL_PS.period_num  desc,
                                        GL_PS.quarter_num DESC)
                      where ROWNUM = 1;
                     -- Call custom hook to get the Ct's preferred GL Date.
                     PO_CUSTOM_FUNDS_PKG.gl_date(x_gl_date, x_gl_period);

                     IF po_log.d_proc THEN
                       PO_LOG.proc_begin(l_log_head, 'x_gl_date', x_gl_date);
                       PO_LOG.proc_begin(l_log_head,
                                         'x_gl_period',
                                         x_gl_period);
                     END IF;
                   exception */
                     when no_data_found THEN
                       x_gl_date := NULL;
          /* Bug14523678
	        end; -- 4th Check
               end; -- 3rd Check */
           end; -- 2nd Check
       END; -- 1st Check
     end build_GL_Encumbered_Date;

   -- GL Date Project#Start:
   --Start of Comments
   --Name: get_gl_date
   --Pre-reqs:
   --  None.
   --Modifies:
   --  None.
   --Locks:
   --  None.
   --Function:
   --  Derive proper GL date, when the profile PO: Validate GL Period has been
   --  set to Redefault.
   --Parameters:
   --IN:
   --x_sob_id
   --  Set of books.
   ----IN OUT:
   --x_gl_date
   --  Date, which needs to be replaced with a correct date, if not open.
   --Notes:
   --  This procedure was written for GL Date (CLM Phase 2) project.
   --  The requirement is to derive a Latest Open Period's GL Date, if the
   --  entered/present GL date is not in Open period. Present procedures
   --  are not helpful the derive GL date for a set of distributions during
   --  PDOI flow.
   --Testing:
   --
   --End of Comments
   -------------------------------------------------------------------------------
   PROCEDURE get_gl_date(x_sob_id  IN NUMBER,
                         x_gl_date IN OUT NOCOPY po_tbl_date) IS

     l_log_head CONSTANT VARCHAR2(100) := g_log_head || ' GET_GL_DATE';
     l_progress  VARCHAR2(3) := '000';
     l_gl_period VARCHAR2(15);
   BEGIN

     IF g_debug_stmt THEN
       PO_DEBUG.debug_begin(l_log_head);
       PO_DEBUG.debug_var(l_log_head, l_progress, 'x_sob_id', x_sob_id);
       PO_DEBUG.debug_var(l_log_head, l_progress, 'x_gl_date', x_gl_date);
     END IF;

     FOR i IN 1 .. x_gl_date.COUNT LOOP
       l_progress := '010';
       build_GL_Encumbered_Date(l_sob_id    => x_sob_id,
                                x_gl_date   => x_gl_date(i),
                                x_gl_period => l_gl_period);
     END LOOP;

     l_progress := '020';

     IF g_debug_stmt THEN
       PO_DEBUG.debug_var(l_log_head, l_progress, 'x_gl_date', x_gl_date);
       PO_DEBUG.debug_end(l_log_head);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF g_debug_unexp THEN
         PO_DEBUG.debug_exc(l_log_head, l_progress);
       END IF;
       RAISE;

   END get_gl_date;
   --14178037 <GL DATE Project End>



-----------------------------------------------------------------------------
-- Initialize package variables.
-----------------------------------------------------------------------------

BEGIN

g_debug_stmt := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp := PO_DEBUG.is_debug_unexp_on;


END PO_PERIODS_SV;

/
