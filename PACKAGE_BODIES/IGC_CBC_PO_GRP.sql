--------------------------------------------------------
--  DDL for Package Body IGC_CBC_PO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CBC_PO_GRP" AS
   -- $Header: IGCBCPOB.pls 120.25.12000000.2 2007/09/07 11:24:39 smannava ship $
   --
   -- Global Variables
      g_org_id   NUMBER := to_number(fnd_profile.value('ORG_ID'));
      G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGC_CBC_PO_GRP';
   --

   -- Some Common Cursors
   -- cursor to return max and min gl dates for PO distributions

   CURSOR c_po_dates(p_document_id  po_distributions.po_header_id%TYPE)
   IS
         SELECT max(pod.gl_encumbered_date)
               ,min(pod.gl_encumbered_date)
         FROM   po_distributions pod,
                po_lines pol,
                po_line_locations poll
         WHERE  pol.po_header_id = p_document_id
         AND    NVL(pol.closed_code,'X') <> 'FINALLY CLOSED'
         AND    NVL(poll.closed_code,'X') <> 'FINALLY CLOSED'
         AND    poll.shipment_type IN ('STANDARD','PLANNED')
         AND    pod.line_location_id = poll.line_location_id
         AND    pod.po_line_id = pol.po_line_id
         AND    poll.po_line_id = pol.po_line_id
         AND    nvl(poll.cancel_flag,'N') = 'N'
         AND    nvl(pol.cancel_flag,'N') = 'N'
         AND    nvl(pod.prevent_encumbrance_flag,'N') = 'N'
         AND    GREATEST( Decode (poll.accrue_on_receipt_flag,
                'N', Nvl(pod.quantity_ordered,0) -
                      Greatest (nvl(pod.quantity_billed,0),
                                Nvl(pod.unencumbered_quantity,0)),
                'Y', nvl(pod.quantity_ordered,0) -
                      Greatest (Nvl(pod.quantity_delivered,0),
                                Nvl(pod.unencumbered_quantity,0)), 0) ,0) > 0 ;


   -- cursor to return max and min gl dates for requisition distributions

   CURSOR c_req_dates(p_document_id  po_requisition_lines.requisition_header_id%TYPE)
   IS
         SELECT max(gl_encumbered_date)
               ,min(gl_encumbered_date)
         FROM   po_req_distributions dists
               ,po_requisition_lines lines
         WHERE  dists.requisition_line_id = lines.requisition_line_id
         AND    lines.requisition_header_id = p_document_id
         AND    NVL(lines.closed_code,'X') <> 'FINALLY CLOSED'
         AND    NVL(lines.cancel_flag,'N') = 'N'
         AND    Nvl(lines.line_location_id,-999) = -999
         AND    lines.source_type_code = 'VENDOR';
--         AND    NVL(dists.prevent_encumbrance_flag,'N') = 'N';

   -- cursor to return max and min gl dates for releases
   CURSOR c_rel_dates(p_document_id  po_distributions.po_release_id%TYPE)
   IS
         SELECT max(pod.gl_encumbered_date)
               ,min(pod.gl_encumbered_date)
         FROM   po_distributions pod,
                po_line_locations poll
         WHERE  pod.po_release_id = p_document_id
         AND    poll.po_release_id = p_document_id
         AND    NVL(poll.closed_code,'X') <> 'FINALLY CLOSED'
         AND    pod.line_location_id = poll.line_location_id
-- ssmales 02-Apr-03 bug 2876775 cancel flag clause below needs nvl
--         AND    poll.cancel_flag = 'N'
         AND    NVL(poll.cancel_flag,'N') = 'N'
         AND    poll.shipment_type IN ('BLANKET','SCHEDULED')
         AND    NVL(pod.prevent_encumbrance_flag,'N') = 'N'
         AND    GREATEST( Decode (poll.accrue_on_receipt_flag,
                'N', Nvl(pod.quantity_ordered,0) -
                      Greatest (nvl(pod.quantity_billed,0),
                                Nvl(pod.unencumbered_quantity,0)),
                'Y', nvl(pod.quantity_ordered,0) -
                      Greatest (Nvl(pod.quantity_delivered,0),
                                Nvl(pod.unencumbered_quantity,0)), 0) ,0) > 0 ;

   -- Cursor to check if the BPA should be encumbered.
   CURSOR  c_chk_bpa_enc (p_po_header_id    NUMBER)
   IS
          SELECT  encumbrance_required_flag
          FROM    po_headers
          WHERE   po_header_id = p_po_header_id;
   --
   -- PUBLIC ROUTINES
   --
   --

   -- *************************************************************************
   --     Get_Fiscal_Year
   -- *************************************************************************

    FUNCTION Get_Fiscal_Year(p_date    IN DATE,
                             p_sob_id  IN NUMBER)
    RETURN number IS

        -- Define cursor to extract the fiscal year for p_date

        CURSOR c_fiscal_year(p_sob_id NUMBER) IS
        SELECT period_year
        FROM gl_periods gp,
             gl_sets_of_books gsob
        WHERE gp.period_set_name = gsob.period_set_name
        AND   gp.period_type = gsob.accounted_period_type
        AND   trunc(p_date) BETWEEN trunc(gp.start_date)
                             AND     trunc(gp.end_date)
        AND   gsob.set_of_books_id = p_sob_id;

        -- Define local variables

        l_fiscal_year            NUMBER;

        -- Define exceptions

        e_fiscal_year_not_found  EXCEPTION;

     BEGIN

        -- Get the fiscal year

        OPEN c_fiscal_year(p_sob_id);

        IF (c_fiscal_year%NOTFOUND) THEN
            RAISE e_fiscal_year_not_found;
        END IF;

        FETCH c_fiscal_year INTO l_fiscal_year;

        CLOSE c_fiscal_year;

        RETURN l_fiscal_year;

     EXCEPTION
        WHEN e_fiscal_year_not_found THEN
             close c_fiscal_year;
             l_fiscal_year := NULL;
             RETURN l_fiscal_year;

     END Get_Fiscal_Year;

   -- *************************************************************************
   --     Is_CBC_enabled
   -- *************************************************************************

    Procedure is_cbc_enabled(p_api_version          IN  NUMBER
                            ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
                            ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
                            ,p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                            ,x_return_status        OUT NOCOPY VARCHAR2
                            ,x_msg_count            OUT NOCOPY NUMBER
                            ,x_msg_data             OUT NOCOPY VARCHAR2
                            ,x_cbc_enabled          OUT NOCOPY VARCHAR2 )
   IS
   CURSOR c_is_cbc_on IS
   SELECT cbc_po_enable
   FROM igc_cc_bc_enable a,
         financials_system_parameters b
   WHERE a.set_of_books_id = b.set_of_books_id;

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'IS_CBC_ENABLED';
   l_cbc_enable             VARCHAR2(1);

   BEGIN

      -- Initialize package variable
      igc_cbc_po_grp.g_is_cbc_po_enabled := 'N';

   -- Standard call to check for call compatibility

     IF (NOT FND_API.Compatible_API_Call(l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,G_PKG_NAME))
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     -- Check p_init_msg_list

     IF FND_API.to_Boolean(p_init_msg_list) THEN

        FND_MSG_PUB.initialize;

     END IF;

    -- Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_is_cbc_on;
    FETCH c_is_cbc_on INTO l_cbc_enable;
    CLOSE c_is_cbc_on;

    IF NVL(l_cbc_enable,'N')= 'N' THEN
       x_cbc_enabled := 'N';
       -- Also set the database package variable
       igc_cbc_po_grp.g_is_cbc_po_enabled := 'N';
    ELSE
       x_cbc_enabled := 'Y';
       igc_cbc_po_grp.g_is_cbc_po_enabled := 'Y';
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_cbc_enabled := 'N';
     igc_cbc_po_grp.g_is_cbc_po_enabled := 'N';
     IF c_is_cbc_on%ISOPEN
     THEN
         CLOSE c_is_cbc_on;
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF c_is_cbc_on%ISOPEN
      THEN
         CLOSE c_is_cbc_on;
      END IF;
      x_cbc_enabled := 'N';
      igc_cbc_po_grp.g_is_cbc_po_enabled := 'N';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      IF c_is_cbc_on%ISOPEN
      THEN
         CLOSE c_is_cbc_on;
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_cbc_enabled := 'N';
      igc_cbc_po_grp.g_is_cbc_po_enabled := 'N';

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                 p_data   => x_msg_data);
   END is_cbc_enabled;

   -- *************************************************************************
   --     cbc_po_enabled_flag
   -- *************************************************************************
   -- This function returns the value stored in variable is_cbc_po_enabled
   -- so that it can be used by forms.
   FUNCTION cbc_po_enabled_flag
          RETURN VARCHAR2
   IS

   BEGIN
      RETURN Nvl(igc_cbc_po_grp.g_is_cbc_po_enabled,'N');

   END;

   -- *************************************************************************
   --     set_fundchk_cancel_flag
   -- *************************************************************************
   -- Procedure to set the package variable to the forms and librarires
   PROCEDURE set_fundchk_cancel_flag (p_value            IN  VARCHAR2)
   IS
   BEGIN

      igc_cbc_po_grp.g_fundchk_cancel_flag := p_value;

   END set_fundchk_cancel_flag;


   -- *************************************************************************
   --     fundchk_cancel_flag
   -- *************************************************************************
   -- This function returns the value stored in variable g_fundchk_cancel_flag
   -- so that it can be used by forms.
   FUNCTION fundchk_cancel_flag
          RETURN VARCHAR2
   IS

   BEGIN
      RETURN Nvl(igc_cbc_po_grp.g_fundchk_cancel_flag,'N');

   END;

   -- *************************************************************************
   --     cbc_header_validations
   -- *************************************************************************

   -- This procedure is used to do single year validations which will stop users
   -- from creating documents with distributions spanning multiple fiscal years
   -- therefore when documents are created the system must check whether all GL
   -- dates are in the same fiscal year or not.

   PROCEDURE cbc_header_validations(
                               p_api_version        IN   NUMBER
                              ,p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE
                              ,p_commit             IN   VARCHAR2 := FND_API.G_FALSE
                              ,p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
                              ,x_return_status      OUT  NOCOPY VARCHAR2
                              ,x_msg_count          OUT  NOCOPY NUMBER
                              ,x_msg_data           OUT  NOCOPY VARCHAR2
                              ,p_document_id        IN   NUMBER
                              ,p_document_type      IN   VARCHAR2
                              ,p_document_sub_type  IN   VARCHAR2) IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'CBC_HEADER_VALIDATIONS';

   l_sob_id                   financials_system_parameters.set_of_books_id%TYPE;
   l_document_id              NUMBER := to_number(p_document_id);
   l_max_gl_date              po_distributions.gl_encumbered_date%TYPE;
   l_min_gl_date              po_distributions.gl_encumbered_date%TYPE;
   l_max_fiscal_year          gl_periods.period_year%TYPE;
   l_min_fiscal_year          gl_periods.period_year%TYPE;
   l_req_encumbrance_flag     financials_system_parameters.req_encumbrance_flag%TYPE;
   l_purch_encumbrance_flag   financials_system_parameters.purch_encumbrance_flag%TYPE;
   e_document_not_found       EXCEPTION;

   BEGIN

      -- standard call to check for call compatibility.

      IF (NOT FND_API.Compatible_API_Call( l_api_version
                                          ,p_api_version
                                          ,l_api_name
                                          ,G_PKG_NAME))
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- check p_init_msg_list

      IF FND_API.to_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- initialize API return status to success

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Find the set of books id and encumbrance flags for requisitions and purchasing

      SELECT set_of_books_id,req_encumbrance_flag,purch_encumbrance_flag
      INTO   l_sob_id,l_req_encumbrance_flag,l_purch_encumbrance_flag
      FROM   financials_system_parameters;


      IF (p_document_type = 'PO')
      AND p_document_sub_type IN ('STANDARD','PLANNED')
      AND NVL(l_purch_encumbrance_flag,'N')='Y'  THEN

         -- Get the minimum and maximum gl dates for the PO distributions

         OPEN c_po_dates(l_document_id);
         FETCH c_po_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_po_dates;

      ELSIF (p_document_type LIKE 'REQ%')
      AND NVL(l_req_encumbrance_flag,'N')='Y'  THEN

         -- Get the minimum and maximum gl dates for the requisition
         -- distributions

         OPEN c_req_dates(l_document_id);
         FETCH c_req_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_req_dates;

      ELSIF (p_document_type LIKE 'REL%')
      AND p_document_sub_type IN ('SCHEDULED','BLANKET')
      AND NVL(l_purch_encumbrance_flag,'N') = 'Y' THEN

         -- Get the minimum and maximum gl dates for the release
         -- distributions

         OPEN c_rel_dates(l_document_id);
         FETCH c_rel_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_rel_dates;

      ELSE
        -- we are not interested in this type of document therefore return successes
        Return;

      END IF;


      -- Get the fiscal year for the min and max gl dates

      l_max_fiscal_year :=
              igc_cbc_po_grp.get_fiscal_year(l_max_gl_date,l_sob_id);
      l_min_fiscal_year :=
              igc_cbc_po_grp.get_fiscal_year(l_min_gl_date,l_sob_id);


      -- The fiscal years are not the same then return error.
      IF (l_max_fiscal_year <> l_min_fiscal_year) THEN

         FND_MESSAGE.Set_Name('IGC','IGC_MULT_FISCAL_YEARS');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

     FND_MSG_PUB.Count_and_Get( p_count => x_msg_count
                               ,p_data  => x_msg_data);

   EXCEPTION
      WHEN e_document_not_found THEN
         fnd_message.set_name('IGC','IGC_DOCUMENT_NOT_FOUND');
         fnd_message.set_token('DOC_ID',p_document_id);
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                                   ,p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                                  ,p_data  => x_msg_data);

      WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME
                                 ,l_api_name);
       END IF;

         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                                   ,p_data  => x_msg_data);

   END cbc_header_validations;


   -- *************************************************************************
   --     valid_cbc_acct_date
   -- *************************************************************************
   -- This procedure validates the CBC Accounting Date.

   PROCEDURE valid_cbc_acct_date( p_api_version       IN   NUMBER
                                 ,p_init_msg_list     IN   VARCHAR2  := FND_API.G_FALSE
                                 ,p_commit            IN   VARCHAR2  := FND_API.G_FALSE
                                 ,p_validation_level  IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL
                                 ,x_return_status     OUT  NOCOPY VARCHAR2
                                 ,x_msg_count         OUT  NOCOPY NUMBER
                                 ,x_msg_data          OUT  NOCOPY VARCHAR2
                                 ,p_document_id       IN   NUMBER
                                 ,p_document_type     IN   VARCHAR2
                                 ,p_document_sub_type IN   VARCHAR2
                                 ,p_cbc_acct_date     IN   DATE)  IS

  l_api_version CONSTANT    NUMBER       := 1.0;
  l_api_name    CONSTANT    VARCHAR2(30) := 'Valid_CBC_Acct_Date';
  l_sob_id                  financials_system_parameters.set_of_books_id%TYPE;
  l_req_encumbrance_flag    financials_system_parameters.req_encumbrance_flag%TYPE;
  l_purch_encumbrance_flag  financials_system_parameters.purch_encumbrance_flag%TYPE;
  l_fiscal_year             NUMBER;
  l_prev_fiscal_year        NUMBER;
  l_dist_max_fiscal_year    NUMBER;
  l_dist_min_fiscal_year    NUMBER;
  l_max_req_fiscal_year     NUMBER;
  l_min_req_fiscal_year     NUMBER;
  l_gl_prd_sts              VARCHAR2(1);
  l_po_prd_sts              VARCHAR2(1);
  l_prev_cbc_acct_date      DATE;
  l_max_gl_date             po_distributions.gl_encumbered_date%TYPE;
  l_min_gl_date             po_distributions.gl_encumbered_date%TYPE;
  l_max_cbc_acc_date        po_requisition_headers.cbc_accounting_date%TYPE;
  l_min_cbc_acc_date        po_requisition_headers.cbc_accounting_date%TYPE;
  l_po_cbc_acct_date        DATE;

  -- Added for PRC.FP.J, 3173178
  l_max_bpa_fiscal_year     NUMBER;
  l_min_bpa_fiscal_year     NUMBER;
  l_max_bpa_accounting_date po_headers.cbc_accounting_date%TYPE;
  l_min_bpa_accounting_date po_headers.cbc_accounting_date%TYPE;

      -- cursor to find the GL period status

      CURSOR c_get_gl_prd_sts(  p_sob_id     IN  NUMBER
                               ,p_date       IN  DATE
                               ,p_appl_name  IN  VARCHAR2)
      IS
         SELECT gps.closing_status
         FROM   gl_period_statuses gps,
                fnd_application app
         WHERE  gps.application_id         = app.application_id
         AND    app.application_short_name = p_appl_name
         AND    gps.set_of_books_id        = p_sob_id
         AND    p_date BETWEEN gps.start_date AND gps.end_date
         AND    gps.adjustment_period_flag = 'N';


      CURSOR c_bpa_dates (p_document_id    IN NUMBER)
      IS
        SELECT MAX(pod.gl_encumbered_date),
               MIN(pod.gl_encumbered_date)
        FROM    po_distributions pod
        WHERE   pod.po_header_id = p_document_id
        AND     pod.distribution_type = 'AGREEMENT';

   l_bpa_enc_required_flag        VARCHAR2(1);

   BEGIN

      -- Standard Call to check for call compatibility

      IF (NOT FND_API.Compatible_API_Call( l_api_version
                                          ,p_api_version
                                          ,l_api_name
                                          ,G_PKG_NAME))
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Check p_init_msg_list

      IF FND_API.to_Boolean( p_init_msg_list)
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Get the set of books id and encumbrance flags for requisitions and purchasing

      SELECT req_encumbrance_flag
            ,purch_encumbrance_flag
            ,set_of_books_id
      INTO   l_req_encumbrance_flag
            ,l_purch_encumbrance_flag
            ,l_sob_id
      FROM   financials_system_parameters;

      -- Check if we need to perform any validations

      IF    NOT((p_document_type = 'PO'
             AND p_document_sub_type IN ('STANDARD','PLANNED')
             AND NVL(l_purch_encumbrance_flag,'N') = 'Y')

             OR

             (p_document_type LIKE 'REQ%'
             AND NVL(l_req_encumbrance_flag,'N') = 'Y')

             OR

             (p_document_type LIKE 'REL%'
             AND p_document_sub_type IN ('SCHEDULED','BLANKET')
             AND NVL(l_purch_encumbrance_flag,'N') = 'Y')

             OR

             -- Added for 3173178, BPAs will be encumbered
             (p_document_type IN ('PA','PO')
              AND p_document_sub_type = 'BLANKET'
              AND Nvl( l_req_encumbrance_flag,'N') = 'Y'))

      THEN

         -- Accounting Date should not be validated for the above

         Return;

      END IF;

      -- Added for 3173178, check if this particular BPA should be encumbered.
      IF  p_document_type IN ('PA','PO')
      AND p_document_sub_type = 'BLANKET'
      THEN
          OPEN c_chk_bpa_enc(p_document_id);
          FETCH c_chk_bpa_enc INTO l_bpa_enc_required_flag;
          CLOSE c_chk_bpa_enc;

          IF Nvl(l_bpa_enc_required_flag,'N') = 'N'
          THEN
              RETURN;
          END IF;
      END IF;


      -- Ensure the accounting date is not null

      IF (p_cbc_acct_date is NULL) THEN
         FND_MESSAGE.SET_NAME('IGC','IGC_PO_ACCT_DATE_NULL');
         FND_MSG_PUB.Add;
         X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count   =>  x_msg_count
                                   ,p_data    =>  x_msg_data);
         RETURN;
      END IF;

      -- Get the Fiscal year for the entered accounting date

      l_fiscal_year := IGC_CBC_PO_GRP.GET_FISCAL_YEAR(p_cbc_acct_date, l_sob_id);

      -- Check Fiscal year is not null

      IF l_fiscal_year is NULL THEN

        FND_MESSAGE.SET_NAME('IGC','IGC_FISCAL_YEAR_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CBC_DATE',p_cbc_acct_date);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count   =>  x_msg_count
                                  ,p_data    =>  x_msg_data);
        Return;

      END IF;

      -- Get status of PO Period

      OPEN c_get_gl_prd_sts( l_sob_id, p_cbc_acct_date, 'PO');
      FETCH c_get_gl_prd_sts into l_po_prd_sts;
      CLOSE c_get_gl_prd_sts;

      -- Check the accounting date is an open purchasing period

      IF l_po_prd_sts <> 'O'
         THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_PO_PERIOD_NOT_OPEN');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Get status of GL Period

      OPEN c_get_gl_prd_sts( l_sob_id, p_cbc_acct_date, 'SQLGL');
      FETCH c_get_gl_prd_sts into l_gl_prd_sts;
      CLOSE c_get_gl_prd_sts;

      -- Check the accounting date is in an open or future entry GL period

      IF l_gl_prd_sts NOT IN ('O','F') THEN

           FND_MESSAGE.SET_NAME('IGC', 'IGC_GL_PERIOD_NOT_OPEN_OR_FE');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      -- get the previous cbc accounting date

      IF p_document_type IN ('PA', 'PO') THEN

          SELECT cbc_accounting_date
          INTO l_prev_cbc_acct_date
          FROM po_headers
          WHERE po_header_id = p_document_id;

      ELSIF (p_document_type LIKE 'REL%') THEN

          SELECT cbc_accounting_date
          INTO l_prev_cbc_acct_date
          FROM po_releases
          WHERE po_release_id = p_document_id;

      ELSIF (p_document_type LIKE 'REQ%') THEN

         SELECT cbc_accounting_date
         INTO l_prev_cbc_acct_date
         FROM po_requisition_headers
         WHERE requisition_header_id = p_document_id;

      END IF;

      IF l_prev_cbc_acct_date is NOT NULL THEN

         -- Check that the accounting date is equal to or
         -- later than the previous accounting date

         IF (p_cbc_acct_date < l_prev_cbc_acct_date) THEN

             FND_MESSAGE.SET_NAME('IGC','IGC_CC_ACCT_DATE_BEFORE_PREV');
             FND_MESSAGE.SET_TOKEN('ACCT_DATE',p_cbc_acct_date);
             FND_MESSAGE.SET_TOKEN('PREV_DATE',l_prev_cbc_acct_date);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

         -- Get the previous accounting date fiscal year

         l_prev_fiscal_year := igc_cbc_po_grp.get_fiscal_year( l_prev_cbc_acct_date, l_sob_id);

         -- The fiscal year must be the same as the previous accounting date fiscal year

         IF (l_prev_fiscal_year <> l_fiscal_year) THEN

             FND_MESSAGE.SET_NAME('IGC','IGC_FISCAL_YEAR_DIFF');
             FND_MESSAGE.SET_TOKEN('ACCT_DATE',p_cbc_acct_date);
             FND_MESSAGE.SET_TOKEN('PREV_DATE',l_prev_cbc_acct_date);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

     END IF;

     -- Now check that this fiscal year is the same as the fiscal year
     -- of the GL dates on all the distributions for this document.
     -- All the distributions should be in the same fiscal year

      IF p_document_type = 'PO'
      AND p_document_sub_type IN ('STANDARD', 'PLANNED') -- Bug 3173178
      THEN
         -- Get the minimum and maximum gl dates for the PO distributions

         OPEN c_po_dates(p_document_id);
         FETCH c_po_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_po_dates;

      ELSIF p_document_type LIKE 'REQ%'
      THEN
         -- Get the minimum and maximum gl dates for the requisition
         -- distributions

         OPEN c_req_dates(p_document_id);
         FETCH c_req_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_req_dates;

      ELSIF p_document_type LIKE 'REL%'
      THEN
         -- Get the minimum and maximum gl dates for the release
         -- distributions

         OPEN c_rel_dates(p_document_id);
         FETCH c_rel_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_rel_dates;

      ELSIF p_document_type IN ('PA','PO')
      AND   p_document_sub_type = 'BLANKET'
      THEN
         OPEN c_bpa_dates (p_document_id);
         FETCH c_bpa_dates INTO l_max_gl_date, l_min_gl_date;
         CLOSE c_bpa_dates;

      END IF;

     l_dist_max_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_max_gl_date,
                                                              l_sob_id);

     l_dist_min_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_min_gl_date,
                                                              l_sob_id);

     -- If the accounting date fiscal year does not match the fiscal year
     -- on the distributions then raise error.
     IF   l_fiscal_year <> l_dist_max_fiscal_year
     AND  l_fiscal_year <> l_dist_min_fiscal_year
     THEN

        FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_FY_AFTER_DISTS');
        FND_MESSAGE.SET_TOKEN('ACCT_YEAR',l_fiscal_year);
        FND_MESSAGE.SET_TOKEN('DIST_YEAR',l_dist_max_fiscal_year);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;

     -- Accounting date should preferrably be before the least GL date
     IF (p_cbc_acct_date > l_min_gl_date) THEN

        FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_AFTER_GL_DATES');
        FND_MSG_PUB.Add;

     END IF;


     -- Bug 2782411 - only check for related documents if the cbc_accounting_date is null
     -- If statement below added
     IF l_prev_cbc_acct_date IS NULL THEN

        -- If this is a purchase order or a release which was created FROM requisitions,
        -- need to ckeck the accounting date on the associated requisitions
        -- is lesser or equal to the accounting date being validated.
        -- The fiscal years of all the accounting dates should be the same.

        IF (p_document_type = 'PO')
        AND p_document_sub_type IN ('STANDARD', 'PLANNED')
        THEN
           SELECT max(prh.cbc_accounting_date),
                  min(prh.cbc_accounting_date)
           INTO l_max_cbc_acc_date,
                l_min_cbc_acc_date
           FROM po_requisition_headers prh,
                po_requisition_lines   prl,
                po_line_locations      poll
           WHERE poll.po_header_id     = p_document_id
           AND   poll.line_location_id = prl.line_location_id
           AND   prl.requisition_header_id = prh.requisition_header_id
           AND   NVL(prl.closed_code,'X') <> 'FINALLY CLOSED'
           AND   NVL(prl.cancel_flag,'N') = 'N'
           AND   NVL(poll.closed_code,'X') <> 'FINALLY CLOSED'
           AND   NVL(poll.cancel_flag,'N') = 'N'
           AND   prl.source_type_code = 'VENDOR';


        ELSIF (p_document_type LIKE 'REL%') THEN

           SELECT max(prh.cbc_accounting_date),
                  min(prh.cbc_accounting_date)
           INTO   l_max_cbc_acc_date,
                 l_min_cbc_acc_date
           FROM   po_requisition_headers prh,
                 po_requisition_lines   prl,
                 po_line_locations      poll
           WHERE  poll.po_release_id = p_document_id
           AND    prl.line_location_id = poll.line_location_id
           AND    prl.requisition_header_id = prh.requisition_header_id
           AND    NVL(prl.closed_code,'X') <> 'FINALLY CLOSED'
           AND    NVL(prl.cancel_flag,'N') = 'N'
           AND    NVL(poll.closed_code,'X') <> 'FINALLY CLOSED'
           AND    NVL(poll.cancel_flag,'N') = 'N'
           AND    prl.source_type_code = 'VENDOR';

        END IF;

        IF  l_max_cbc_acc_date is NOT NULL
        AND l_min_cbc_acc_date IS NOT NULL
        THEN
            IF p_cbc_acct_date < l_max_cbc_acc_date
            THEN
                FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_BEFORE_REQ_DATE');
                FND_MESSAGE.SET_TOKEN('ACCT_DATE',p_cbc_acct_date);
                FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;

           END IF;

           l_max_req_fiscal_year := igc_cbc_po_grp.get_fiscal_year(
                                     l_max_cbc_acc_date, l_sob_id);
           l_min_req_fiscal_year := igc_cbc_po_grp.get_fiscal_year(
                                     l_min_cbc_acc_date, l_sob_id);

           -- Check if the fiscal year is the same for the accounting date on
           -- the associated documents.
           IF (l_fiscal_year <> l_max_req_fiscal_year) OR
           (l_fiscal_year <> l_min_req_fiscal_year )
           THEN
               FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_FY_DIFF_REQ');
               FND_MESSAGE.SET_TOKEN('ACCT_YEAR',l_fiscal_year);
               FND_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
       END IF;

       -- Will Check Releases Accounting Date with that of PO Headers,
       -- If it is less than the cbc accounting date in PO Headers then it will be rejected.

       IF p_document_type LIKE 'REL%' AND
          p_document_sub_type IN ( 'SCHEDULED', 'BLANKET') THEN

          select po.cbc_accounting_date
          into l_po_cbc_acct_date
          from po_headers po, po_releases por
          where po.po_header_id = por.po_header_id
          and por.po_release_id = p_document_id;

          IF p_cbc_acct_date < l_po_cbc_acct_date THEN

             FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_BEFORE_PO_DATE');
             FND_MESSAGE.SET_TOKEN('ACCT_DATE', p_cbc_acct_date);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;

          -- ssmales 05-Feb-2003 bug 2784922 start
          IF l_fiscal_year <> igc_cbc_po_grp.get_fiscal_year(
                                  l_po_cbc_acct_date, l_sob_id) THEN
             FND_MESSAGE.SET_NAME('IGC','IGC_ACCT_DATE_FY_DIFF_PO');
             FND_MESSAGE.SET_TOKEN('ACCT_DATE', l_fiscal_year);
             FND_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          -- ssmales 05-Feb-2003 bug 2784922 end

       END IF;

       -- Added for PRC.FP.J, 3173178, Start
       -- Checks if the documents are sourced from an encumbered BPA.
       -- In that case, the accounting date on the current document
       -- should be in the same fiscal year as the accounting date
       -- of the BPA and should be later than the accounting date of the BPA.
       IF p_document_type LIKE 'REQ%'
       THEN
           -- Req sourced from BPA
           SELECT MAX(poh.cbc_accounting_date),
                  MIN(poh.cbc_accounting_date)
           INTO   l_max_bpa_accounting_date,
                  l_min_bpa_accounting_date
           FROM   po_headers poh,
                  Po_requisition_lines prl
           WHERE  prl.requisition_header_id = p_document_id
           AND    prl.blanket_po_header_id  = poh.po_header_id
           AND    prl.blanket_po_header_id  IS NOT NULL
           AND    poh.type_lookup_code = 'BLANKET'
           AND    poh.encumbrance_required_flag = 'Y'
           AND    NVL(prl.closed_code,'X') <> 'FINALLY CLOSED'
           AND    NVL(prl.cancel_flag,'N') = 'N';

       ELSIF p_document_type = 'PO'
       AND   p_document_sub_type = 'STANDARD'
       THEN
           -- PO sourced from BPA.
           SELECT MAX(bpa_h.cbc_accounting_date),
                  MIN(bpa_h.cbc_accounting_date)
           INTO   l_max_bpa_accounting_date,
                  l_min_bpa_accounting_date
           FROM   po_headers bpa_h,
                  Po_lines  pol,
                  Po_line_locations poll,
                  Po_distributions bpa_d
           WHERE  pol.po_header_id = p_document_id
           AND    poll.po_line_id = pol.po_line_id
           AND    NVL(pol.closed_code,'X') <> 'FINALLY CLOSED'
           AND    NVL(pol.cancel_flag,'N') = 'N'
           AND    NVL(poll.closed_code,'X') <> 'FINALLY CLOSED'
           AND    NVL(poll.cancel_flag,'N') = 'N'
           AND    pol.from_header_id IS NOT NULL
           AND    pol.from_header_id = bpa_d.po_header_id
           AND    bpa_d.distribution_type = 'AGREEMENT'
           AND    bpa_d.po_header_id = bpa_h.po_header_id
           AND    bpa_h.type_lookup_code = 'BLANKET'
           AND    bpa_h.encumbrance_required_flag  = 'Y';

       END IF;

       IF l_max_bpa_accounting_date is NOT NULL
       AND l_min_bpa_accounting_date IS NOT NULL
       THEN
           IF p_cbc_acct_date < l_max_bpa_accounting_date
           THEN
               FND_MESSAGE.SET_NAME('IGC', 'IGC_ACCT_DATE_BEFORE_BPA_DATE');
               FND_MESSAGE.SET_TOKEN('ACCT_DATE', p_cbc_acct_date);
               FND_MSG_PUB.Add;
               X_return_Status := FND_API.G_RET_STS_ERROR;
           END IF;

           l_max_bpa_fiscal_year := igc_cbc_po_grp.get_fiscal_year
                                    (l_max_bpa_accounting_date, l_sob_id);
           l_min_bpa_fiscal_year := igc_cbc_po_grp.get_fiscal_year
                                    ( l_min_bpa_accounting_date, l_sob_id);

           IF (l_fiscal_year <> l_max_bpa_fiscal_year)
           OR (l_fiscal_year <> l_min_bpa_fiscal_year)
           THEN
               FND_MESSAGE.SET_NAME('IGC', 'IGC_ACCT_DATE_FY_DIFF_BPA');
               FND_MESSAGE.SET_TOKEN('ACCT_YEAR', l_fiscal_year);
               FND_MSG_PUB.Add;
               X_return_Status := FND_API.G_RET_STS_ERROR;
           END IF;
       END IF;

       -- Added for PRC.FP.J, 3173178, End

     -- Bug 2782411 - only check for related documents if the cbc_accounting_date is null
     -- End If statement below added
     END IF;

    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                               p_data  => x_msg_data);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                    p_data  => x_msg_data);

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                    p_data  => x_msg_data);


   END valid_cbc_acct_date;

   -- *************************************************************************
   --     get_cbc_acct_date
   -- *************************************************************************
   -- This procedure returns the CBC Accounting Date that is stored in the database
   -- If one is not found and if a default value is required it determines
   -- and returns a default value.

      PROCEDURE get_cbc_acct_date
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT      NOCOPY VARCHAR2 ,
  x_msg_count                     OUT      NOCOPY NUMBER ,
  x_msg_data                      OUT      NOCOPY VARCHAR2 ,
  p_document_id                   IN       NUMBER,
  p_document_type                 IN       VARCHAR2,
  p_document_sub_type             IN       VARCHAR2,
  p_default                       IN       VARCHAR2,
  x_cbc_acct_date                 OUT      NOCOPY DATE
) AS

   l_api_version           CONSTANT    NUMBER := 1.0 ;
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Get_CBC_Acct_Date' ;

   e_igc_doc_not_found       EXCEPTION;

   l_accounting_date       DATE   :=  NULL;
   l_return_status         VARCHAR2(1) ;
   l_req_enc_flag          VARCHAR2(1) ;
   l_pur_enc_flag          VARCHAR2(1) ;
   l_sob_id                NUMBER;

-- Cursor to get accounting date FROM PO headers for this document
   Cursor c_get_po_date IS
      SELECT cbc_accounting_date
      FROM po_headers
      WHERE po_header_id = p_document_id ;

-- Cursor to get accounting date FROM PO_Req headers for this document
   Cursor c_get_req_date IS
      SELECT cbc_accounting_date
      FROM po_requisition_headers
      WHERE requisition_header_id = p_document_id ;

-- Cursor to get accounting date FROM PO_Rel headers for this document
   Cursor c_get_rel_date IS
      SELECT cbc_accounting_date
      FROM po_releases
      WHERE po_release_id = p_document_id ;

-- Cursor to get the start date of the next open period
   Cursor c_next_period_date(p_sob_id NUMBER) IS
      SELECT start_date
      FROM gl_period_statuses a,
           fnd_application    b
      WHERE a.application_id = b.application_id
      AND   b.application_short_name = 'PO'
      AND   a.set_of_books_id = p_sob_id
      AND   a.closing_status = 'O'
      AND   a.start_date > sysdate
      AND   a.adjustment_period_flag = 'N'
      order by start_date asc ;

 -- Cursor to get the latest accounting date FROM requisitions relating to the PO
-- Bug 2885953 - amended cursor below for performance enhancements
--   Cursor c_max_req_date IS
--      SELECT max(r.cbc_accounting_date)
--      FROM po_requisition_headers  r,
--           po_distributions_v  p
--      WHERE r.requisition_header_id = p.requisition_header_id
--      AND   p.po_header_id = p_document_id;
   Cursor c_max_req_date IS
      SELECT max(porh.cbc_accounting_date)
      FROM po_requisition_headers  porh,
           po_distributions  pod,
           po_requisition_lines porl,
           po_req_distributions pord
      WHERE pod.po_header_id = p_document_id
      AND   pod.req_distribution_id = pord.distribution_id(+)
      AND   pord.requisition_line_id = porl.requisition_line_id(+)
      AND   porl.requisition_header_id = porh.requisition_header_id;


-- Cursor to get the latest accounting date FROM requisitons relating to the Release
-- Bug 2885953 - amended cursor below for performance enhancements
--   Cursor c_max_rel_req_date IS
--      SELECT max(r.cbc_accounting_date)
--      FROM po_requisition_headers  r,
--           po_distributions_v  p
--      WHERE r.requisition_header_id = p.requisition_header_id
--      AND   p.po_release_id = p_document_id;
   Cursor c_max_rel_req_date IS
      SELECT max(porh.cbc_accounting_date)
      FROM po_requisition_headers  porh,
           po_distributions  pod,
           po_requisition_lines porl,
           po_req_distributions pord
      WHERE pod.po_release_id = p_document_id
      AND   pod.req_distribution_id = pord.distribution_id(+)
      AND   pord.requisition_line_id = porl.requisition_line_id(+)
      AND   porl.requisition_header_id = porh.requisition_header_id;


-- Cursor to get the latest accounting date FROM PO's relating to the release
   Cursor c_rel_po_date IS
      SELECT poh.cbc_accounting_date
      FROM po_releases  por,
           po_headers   poh
      WHERE  por.po_release_id = p_document_id
      AND    por.po_header_id  = poh.po_header_id ;

 -- Cursor to get financial information
   Cursor c_fin_info IS
      SELECT req_encumbrance_flag,
             purch_encumbrance_flag,
             set_of_books_id
      FROM financials_system_parameters ;

   -- Added for PRC.FP.J, get the accounting date for the
   -- Blanket Agreements for Standard Purchase Orders.
   Cursor c_max_bpa_po_date IS
      SELECT max(bpa_h.cbc_accounting_date)
      FROM   po_headers bpa_h,
             Po_lines pol,
             Po_distributions bpa_d
      WHERE  pol.po_header_id = p_document_id
      AND    pol.from_header_id IS NOT NULL
      AND    pol.from_header_id = bpa_d.po_header_id
      AND    bpa_d.po_header_id = bpa_h.po_header_id
      AND    bpa_d.distribution_type = 'AGREEMENT'
      AND    bpa_h.type_lookup_code = 'BLANKET'
      AND    bpa_h.encumbrance_required_flag  = 'Y';

   -- Get the accounting date for the backing blanket agreements
   -- for the requisitions.
   Cursor c_max_bpa_req_date IS
      SELECT MAX(bpa_h.cbc_accounting_date)
      FROM   po_headers bpa_h,
             Po_requisition_lines prl
      WHERE  prl.requisition_header_id = p_document_id
      AND    prl.blanket_po_header_id  = bpa_h.po_header_id
      AND    prl.blanket_po_header_id  IS NOT NULL
      AND    bpa_h.type_lookup_code = 'BLANKET'
      AND    bpa_h.encumbrance_required_flag = 'Y'
      AND    NVL(prl.closed_code,'X') <> 'FINALLY CLOSED'
      AND    NVL(prl.cancel_flag,'N') = 'N';

   l_bpa_enc_required_flag        VARCHAR2(1);
   l_bpa_accounting_date          DATE;
   l_req_accounting_date          DATE;

 BEGIN

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                     )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   -- Check p_init_msg_list
   IF FND_API.To_Boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.Initialize ;
   END IF ;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS ;
   l_return_status := FND_API.G_RET_STS_SUCCESS ;

   OPEN c_fin_info ;
   FETCH c_fin_info INTO l_req_enc_flag,
                         l_pur_enc_flag,
                         l_sob_id ;
   CLOSE c_fin_info ;

   IF NOT((p_document_type = 'PO'
   AND p_document_sub_type IN ('STANDARD','PLANNED')
   AND NVL(l_pur_enc_flag,'N') = 'Y')
   OR
   (p_document_type LIKE 'REQ%'
   AND  NVL(l_req_enc_flag,'N') = 'Y')
   OR
   (p_document_type LIKE 'REL%'
   AND p_document_sub_type IN ('SCHEDULED','BLANKET')
   AND NVL(l_pur_enc_flag,'N') = 'Y')
   OR
   (p_document_type IN ( 'PA', 'PO')
   AND p_document_sub_type = 'BLANKET'
   AND NVL(l_req_enc_flag,'N') = 'Y'))
   THEN
      -- Accounting Date should not be defaulted
      RETURN ;
   END IF ;

   -- Added for 3173178, check if this particular BPA should be encumbered.
   IF  p_document_type IN ('PA','PO')
   AND p_document_sub_type = 'BLANKET'
   THEN
       OPEN c_chk_bpa_enc(p_document_id);
       FETCH c_chk_bpa_enc INTO l_bpa_enc_required_flag;
       CLOSE c_chk_bpa_enc;

       IF Nvl(l_bpa_enc_required_flag,'N') = 'N'
       THEN
           RETURN;
       END IF;
   END IF;

   -- Get the existing Accounting Date
   IF p_document_type IN ('PO', 'PA') -- Bug 3173178
   THEN

      OPEN c_get_po_date ;
      FETCH c_get_po_date INTO l_accounting_date ;
      IF c_get_po_date%NOTFOUND
      THEN
         CLOSE c_get_po_date ;
         RAISE e_igc_doc_not_found ;
      END IF ;
   ELSIF p_document_type LIKE 'REQ%'
   THEN
      OPEN c_get_req_date ;
      FETCH c_get_req_date INTO l_accounting_date ;
      IF c_get_req_date%NOTFOUND
      THEN
         CLOSE c_get_req_date ;
         RAISE e_igc_doc_not_found ;
      END IF ;
   ELSIF p_document_type LIKE 'REL%'
   THEN
      OPEN c_get_rel_date ;
      FETCH c_get_rel_date INTO l_accounting_date ;
      IF c_get_rel_date%NOTFOUND
      THEN
         CLOSE c_get_rel_date ;
         RAISE e_igc_doc_not_found ;
      END IF ;
   END IF ;

 -- If we need to provide a default accounting date, then try and get a valid accounting date
   IF p_default = 'Y'
   THEN
      igc_cbc_po_grp.valid_cbc_acct_date(
                                         p_api_version        =>  1.0,
                                         p_init_msg_list      =>  FND_API.G_FALSE,
                                         p_commit             =>  FND_API.G_FALSE,
                                         p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,
                                         x_return_status      =>  l_return_status,
                                         x_msg_count          =>  x_msg_count,
                                         x_msg_data           =>  x_msg_data,
                                         p_document_id        =>  p_document_id,
                                         p_document_type      =>  p_document_type,
                                         p_document_sub_type  =>  p_document_sub_type,
                                         p_cbc_acct_date      =>  l_accounting_date
                                        ) ;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
         -- If date is not valid, get the maximum Acct date FROM related
         -- backing agreements or requisitions
         IF p_document_type LIKE  'REQ%'
         THEN
            -- Added for PRC.FP.J, 3173178
            -- As Requisitions can now have backing BPAs
            l_accounting_date := NULL;
            OPEN  c_max_bpa_req_date ;
            FETCH c_max_bpa_req_date INTO l_accounting_date ;
            CLOSE c_max_bpa_req_date ;

         ELSIF p_document_type = 'PO'
         THEN
            -- Added for PRC.FP.J, 3173178
            -- Get the accounting date from the BPA and requisition
            -- and then use the one which is the greatest of the two
            l_accounting_date := NULL;
            l_req_accounting_date := NULL;
            l_bpa_accounting_date := NULL;
            IF p_document_sub_type = 'STANDARD'
            THEN
                OPEN  c_max_bpa_po_date ;
                FETCH c_max_bpa_po_date INTO l_bpa_accounting_date ;
                CLOSE c_max_bpa_po_date ;
            END IF;

            -- Check if the accounting date is available from Requisitions
            -- This is true for planned or standard POs
            -- End of code added for PRC.FP.J, 3173178
            OPEN c_max_req_date ;
            FETCH c_max_req_date INTO l_req_accounting_date ;
            CLOSE c_max_req_date ;

            l_accounting_date := Nvl(Nvl(greatest (l_req_accounting_date,
                                                   l_bpa_accounting_date),
                                          l_req_accounting_date),
                                     l_bpa_accounting_date);

         ELSIF p_document_type LIKE 'REL%'
         -- AND p_document_sub_type = 'SCHEDULED'
         THEN
            l_accounting_date := NULL;
            l_req_accounting_date := NULL;

            -- Check if accounting date available from Planned PO related
            -- to this Release
            -- Modified for PRC.FP.J, as now even a Blanket PO can have
            -- accounting date
            OPEN c_rel_po_date ;
            FETCH c_rel_po_date INTO l_accounting_date ;
            CLOSE c_rel_po_date ;

            IF p_document_sub_type = 'BLANKET'
            THEN
                -- Check if accounting date available FROM Req's
                -- related to this Release
                OPEN c_max_rel_req_date ;
                FETCH c_max_rel_req_date INTO l_req_accounting_date ;
                CLOSE c_max_rel_req_date ;

                -- Choose the greatest between the accounting date on the BPA
                -- and the one on the requisition
                l_accounting_date := Nvl(Nvl(greatest (l_req_accounting_date,
                                                   l_accounting_date),
                                          l_req_accounting_date),
                                     l_accounting_date);

            END IF;
         END IF ;

         -- Validate this accounting Date
         igc_cbc_po_grp.valid_cbc_acct_date(
                                               p_api_version        =>  1.0,
                                               p_init_msg_list      =>  FND_API.G_FALSE,
                                               p_commit             =>  FND_API.G_FALSE,
                                               p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,
                                               x_return_status      =>  l_return_status,
                                               x_msg_count          =>  x_msg_count,
                                               x_msg_data           =>  x_msg_data,
                                               p_document_id        =>  p_document_id,
                                               p_document_type      =>  p_document_type,
                                               p_document_sub_type  =>  p_document_sub_type,
                                               p_cbc_acct_date      =>  l_accounting_date
                                              ) ;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
            -- Accounting Date not found, try using system date
            l_accounting_date := TRUNC(sysdate) ;
            igc_cbc_po_grp.valid_cbc_acct_date(
                                               p_api_version        =>  1.0,
                                               p_init_msg_list      =>  FND_API.G_FALSE,
                                               p_commit             =>  FND_API.G_FALSE,
                                               p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,
                                               x_return_status      =>  l_return_status,
                                               x_msg_count          =>  x_msg_count,
                                               x_msg_data           =>  x_msg_data,
                                               p_document_id        =>  p_document_id,
                                               p_document_type      =>  p_document_type,
                                               p_document_sub_type  =>  p_document_sub_type,
                                               p_cbc_acct_date      =>  l_accounting_date
                                               ) ;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               -- Sysdate is not valid, so get the first date of next open period
               OPEN c_next_period_date(l_sob_id) ;
               FETCH c_next_period_date INTO l_accounting_date ;
               IF c_next_period_date%FOUND
               THEN
                  igc_cbc_po_grp.valid_cbc_acct_date(
                                                     p_api_version        =>  1.0,
                                                     p_init_msg_list      =>  FND_API.G_FALSE,
                                                     p_commit             =>  FND_API.G_FALSE,
                                                     p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL,
                                                     x_return_status      =>  l_return_status,
                                                     x_msg_count          =>  x_msg_count,
                                                     x_msg_data           =>  x_msg_data,
                                                     p_document_id        =>  p_document_id,
                                                     p_document_type      =>  p_document_type,
                                                     p_document_sub_type  =>  p_document_sub_type,
                                                     p_cbc_acct_date      =>  l_accounting_date
                                                     ) ;
               END IF ; -- c_next_period_date%FOUND
               CLOSE c_next_period_date ;
            END IF ; -- sysdate return_status <> Success
         END IF ; -- requisition date return status <> Success
      END IF ; -- cbc accounting date return status <> Success
   END IF ; -- p_default = 'Y'

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_cbc_acct_date := NULL ;
   ELSE
      x_cbc_acct_date := l_accounting_date ;
   END IF ;

   FND_MSG_PUB.COUNT_AND_GET(
                             p_count  =>  x_msg_count,
                             p_data   =>  x_msg_data
                            ) ;



EXCEPTION
   WHEN e_igc_doc_not_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IGC','IGC_DOCUMENT_NOT_FOUND') ;
      FND_MESSAGE.SET_TOKEN('DOC_ID',p_document_id);
      FND_MSG_PUB.ADD ;
      FND_MSG_PUB.COUNT_AND_GET(
                                p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data
                               ) ;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.ADD_EXC_MSG(
                                 G_PKG_NAME,
                                 l_api_name
                                ) ;
      END IF ;
      FND_MSG_PUB.COUNT_AND_GET(
                                p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data
                               ) ;

END get_cbc_acct_date ;


   -- *************************************************************************
   --     UPDATE_cbc_acct_date
   -- *************************************************************************
   -- Tbis procedure updates the CBC Acounting Date on the PO tables
   -- It is called from within the PO forms.

   PROCEDURE UPDATE_cbc_acct_date
(
  p_api_version                   IN       NUMBER,
  p_init_msg_list                 IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT      NOCOPY VARCHAR2 ,
  x_msg_count                     OUT      NOCOPY NUMBER ,
  x_msg_data                      OUT      NOCOPY VARCHAR2 ,
  p_document_id                   IN       NUMBER,
  p_document_type                 IN       VARCHAR2,
  p_document_sub_type             IN       VARCHAR2,
  p_cbc_acct_date                 IN       DATE
) AS

   l_api_version           CONSTANT    NUMBER := 1.0 ;
   l_api_name              CONSTANT    VARCHAR2(30)  := 'UPDATE_cbc_acct_date' ;
   l_req_enc_flag          VARCHAR2(1) ;
   l_pur_enc_flag          VARCHAR2(1) ;
   l_sob_id                NUMBER ;

   e_igc_doc_not_found       EXCEPTION;

-- Cursor to get financial information
   Cursor c_fin_info IS
      SELECT req_encumbrance_flag,
             purch_encumbrance_flag,
             set_of_books_id
      FROM financials_system_parameters ;

   l_bpa_enc_required_flag        VARCHAR2(1);

 BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(
                                      l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME
                                      )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   -- Check p_init_msg_list
   IF FND_API.To_Boolean(p_init_msg_list)
   THEN
      FND_MSG_PUB.Initialize ;
   END IF ;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   OPEN c_fin_info ;
   FETCH c_fin_info INTO l_req_enc_flag,
                         l_pur_enc_flag,
                         l_sob_id ;
   CLOSE c_fin_info ;

    -- Check if we should be storing the date
   IF NOT((p_document_type = 'PO'
   AND  p_document_sub_type IN ('STANDARD','PLANNED')
   AND  NVL(l_pur_enc_flag,'N') = 'Y')
   OR
   (p_document_type LIKE 'REQ%'
   AND  NVL(l_req_enc_flag,'N') = 'Y')
   OR
   (p_document_type LIKE 'REL%'
   AND  p_document_sub_type IN ('SCHEDULED','BLANKET')
   AND  NVL(l_pur_enc_flag,'N') = 'Y')
   OR
   (p_document_type IN ('PA', 'PO')
   AND  p_document_sub_type = 'BLANKET'
   AND  NVL(l_req_enc_flag,'N') = 'Y'))
   THEN
      -- Accounting date should not be updated.
      RETURN ;
   END IF ;

   -- Added for 3173178, check if this particular BPA should be encumbered.
   IF  p_document_type IN ('PA','PO')
   AND p_document_sub_type = 'BLANKET'
   THEN
       OPEN c_chk_bpa_enc(p_document_id);
       FETCH c_chk_bpa_enc INTO l_bpa_enc_required_flag;
       CLOSE c_chk_bpa_enc;

       IF Nvl(l_bpa_enc_required_flag,'N') = 'N'
       THEN
           RETURN;
       END IF;
   END IF;

   IF p_document_type IN ('PA', 'PO')
   THEN
-- Bug 2885953 added if statement and removed nvl from update for performance enhancement
      IF p_cbc_acct_date IS NOT NULL THEN
         UPDATE po_headers
--         SET cbc_accounting_date = NVL(p_cbc_acct_date, cbc_accounting_date)
         SET cbc_accounting_date = p_cbc_acct_date
         WHERE po_header_id = p_document_id ;

         IF SQL%ROWCOUNT = 0
         THEN
            RAISE e_igc_doc_not_found ;
         END IF ;
      END IF ;

   ELSIF (p_document_type LIKE 'REL%')
   THEN
-- Bug 2885953 added if statement and removed nvl from update for performance enhancement
      IF p_cbc_acct_date IS NOT NULL THEN
         UPDATE po_releases
--         SET cbc_accounting_date = NVL(p_cbc_acct_date, cbc_accounting_date)
         SET cbc_accounting_date = p_cbc_acct_date
         WHERE po_release_id = p_document_id ;

         IF SQL%ROWCOUNT = 0
         THEN
            RAISE e_igc_doc_not_found ;
         END IF ;
      END IF ;

   ELSIF (p_document_type LIKE 'REQ%')
   THEN
-- Bug 2885953 added if statement and removed nvl from update for performance enhancement
      IF p_cbc_acct_date IS NOT NULL THEN
         UPDATE po_requisition_headers
--         SET cbc_accounting_date = NVL(p_cbc_acct_date, cbc_accounting_date)
         SET cbc_accounting_date = p_cbc_acct_date
         WHERE requisition_header_id = p_document_id ;

         IF SQL%ROWCOUNT = 0
         THEN
            RAISE e_igc_doc_not_found ;
         END IF ;
      END IF ;
   END IF ;

   IF FND_API.To_Boolean(p_commit)
   THEN
      COMMIT WORK ;
   END IF ;

   FND_MSG_PUB.Count_and_Get(
                             p_count   =>  x_msg_count,
                             p_data    =>  x_msg_data
                            ) ;

EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.COUNT_AND_GET(
                                p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data
                               ) ;

   WHEN e_igc_doc_not_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IGC','IGC_DOCUMENT_NOT_FOUND') ;
      FND_MSG_PUB.ADD ;
      FND_MSG_PUB.COUNT_AND_GET(
                                p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data
                               ) ;

     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.ADD_EXC_MSG(
                                 G_PKG_NAME,
                                 l_api_name
                                ) ;
      END IF ;
      FND_MSG_PUB.COUNT_AND_GET(
                                p_count   =>  x_msg_count,
                                p_data    =>  x_msg_data
                               ) ;

END  UPDATE_cbc_acct_date ;


   -- *************************************************************************
   --     gl_date_roll_forward
   -- *************************************************************************
   -- This procedure will be called when documents are being cancelled.
   -- It is called from the PO routine in pocca.lpc
   -- For Documents which have backing requisitions, and which have not
   -- been moved forward by the Year End process, this process moves
   -- the GL Date for the reinstated requisition line.

   PROCEDURE gl_date_roll_forward
(
  p_api_version        IN    NUMBER,
  p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level   IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT   NOCOPY VARCHAR2 ,
  x_msg_count          OUT   NOCOPY NUMBER ,
  x_msg_data           OUT   NOCOPY VARCHAR2 ,
  p_document_id        IN    VARCHAR2,
  p_document_type      IN    VARCHAR2,
  p_document_sub_type  IN    VARCHAR2,
  p_line_id            IN    VARCHAR2 := NULL,
  p_line_location_id   IN    VARCHAR2 := NULL,
  p_action_date        IN    DATE,
  p_cancel_req         IN    VARCHAR2
) IS

  l_api_version        CONSTANT   NUMBER        :=  1.0;
  l_api_name           CONSTANT   VARCHAR2(30)  := 'GL_Date_Roll_Forward';

  Cursor c_PO_dists_po IS
  Select p.req_distribution_id,
         p.gl_encumbered_date PO_GL_Date,
         p.set_of_books_id sob_id,
         h.cbc_accounting_date PO_Acct_Date
  From   PO_Distributions_V p,
         PO_Headers h
  Where  p.po_header_id = p_document_id
  And    p.po_line_id   = nvl(p_line_id, p.po_line_id)
  And    p.line_location_id = nvl(p_line_location_id, p.line_location_id)
  And    p.po_header_id = h.po_header_id
  And    p.requisition_header_id is not null;

  l_po_dists_po   c_po_dists_po%rowtype;

-- Bug 2885953 - Performance fixes
--  Cursor c_po_dists_bla_rel IS
--  Select p.req_distribution_id,
--         p.gl_encumbered_date rel_gl_date,
--         p.set_of_books_id sob_id,
--         r.cbc_accounting_date rel_acct_date
--  From   po_distributions_v p,
--         po_releases r
--  Where  p.po_release_id = p_document_id
--  And    p.line_location_id = nvl(p_line_location_id, p.line_location_id)
--  And    p.po_release_id = r.po_release_id
--  And    p.requisition_header_id is not null;
  Cursor c_po_dists_bla_rel IS
  Select pod.req_distribution_id,
         pod.gl_encumbered_date rel_gl_date,
         pod.set_of_books_id sob_id,
         r.cbc_accounting_date rel_acct_date
  From   po_distributions pod,
         po_releases r,
         po_requisition_headers porh,
         po_requisition_lines porl,
         po_req_distributions pord
  Where  pod.po_release_id = p_document_id
  And    pod.line_location_id = nvl(p_line_location_id, pod.line_location_id)
  And    pod.po_release_id = r.po_release_id
  And    porh.requisition_header_id is not null
  And    pod.req_distribution_id = pord.distribution_id(+)
  And    pord.requisition_line_id = porl.requisition_line_id(+)
  And    porl.requisition_header_id = porh.requisition_header_id(+);

  l_po_dists_bla_rel   c_po_dists_bla_rel%rowtype;

  Cursor c_po_dists_sch_rel IS
  Select p.gl_encumbered_date rel_gl_date,
         p.source_distribution_id,
         p.set_of_books_id sob_id,
         r.cbc_accounting_date rel_acct_date
  From   po_distributions_v P,
         po_releases R
  Where  p.po_release_id = p_document_id
  And    p.line_location_id = nvl(p_line_location_id, p.line_location_id)
  And    p.po_release_id = r.po_release_id;

  l_po_dists_sch_rel   c_po_dists_sch_rel%rowtype;

  Cursor c_req_dists (p_req_dist_id NUMBER) IS
  Select gl_encumbered_date
  From   po_req_distributions
  Where  distribution_id = p_req_dist_id;

  l_req_gl_date        Date;

  Cursor c_po_dists (p_source_id NUMBER) IS
  Select gl_encumbered_date
  From   po_distributions
  Where  po_distribution_id = p_source_id;

  l_po_gl_date         Date;

  Cursor c_linked_req_dists (p_req_dist_id NUMBER) IS
  Select distribution_id, gl_encumbered_date
  From   po_req_distributions
  Where  source_req_distribution_id = p_req_dist_id;

  l_linked_req           c_linked_req_dists%rowtype;

  l_fiscal_year          Number;
  l_action_fiscal_year   Number;
  l_acct_fiscal_year     Number;
  l_po_gl_fiscal_year    Number;
  l_rel_gl_fiscal_year   Number;
  l_req_gl_fiscal_year   Number;

  l_req_encumbrance_flag    financials_system_parameters.req_encumbrance_flag%TYPE;
  l_purch_encumbrance_flag  financials_system_parameters.purch_encumbrance_flag%TYPE;
  l_passed_validation    Boolean;

  l_sob_id  financials_system_parameters.set_of_books_id%TYPE;

  Begin

  --Standard Call to check for call compatibility

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Check p_init_msg_list

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  --Initialize API return status to success

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Check if Requisitions are being cancelled, if not then carry on processing

/*
-- Bug 2784359, Commented out the entire procedure GL_Date_Rollforward as it
-- causes other complications. Instead user has been recommended to cancel
-- the backing requisition
-- This is done in the IGILUTIL2.pld and the IGI_CBC.pld

  IF p_cancel_req = 'Y' THEN
     Return;
  END IF;

  SELECT set_of_books_id,req_encumbrance_flag,purch_encumbrance_flag
  INTO   l_sob_id,l_req_encumbrance_flag,l_purch_encumbrance_flag
  FROM   financials_system_parameters;


  --Determine current fiscal year based on sysdate

  l_fiscal_year := igc_cbc_po_grp.get_fiscal_year(sysdate, l_sob_id);

  -- Determine fiscal year of action date.
  -- If same as current year then continue processing

  l_action_fiscal_year := igc_cbc_po_grp.get_fiscal_year(p_action_date, l_sob_id);

  IF l_fiscal_year <> l_action_fiscal_year THEN
     Return;
  END IF;

  --Process PO Documents

  IF p_document_type = 'PO'
  AND NVL(l_purch_encumbrance_flag,'N')='Y'  THEN

  --Standard or Planned PO's only

    IF p_document_sub_type IN ('PLANNED', 'STANDARD')
    THEN

       FOR l_po_dists_po IN c_po_dists_po
       LOOP

       --Initialize validation flag

       l_passed_validation := TRUE;

       -- Determine fiscal year of GL Date of PO Distribution.
       -- If different, from current year then do not proceed

       l_po_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_po_dists_po.po_gl_date, l_po_dists_po.sob_id);

       -- If the GL Date is not in the current fiscal year then do not process.
       IF l_fiscal_year <> l_po_gl_fiscal_year THEN
          l_passed_validation := FALSE;
       END IF;

       IF l_passed_validation THEN

          --Check to see if current distribution on the requisition is obsolete
          -- and if a new requisition line has been created.
          Open c_linked_req_dists(l_po_dists_po.req_distribution_id);
          Fetch c_linked_req_dists into l_linked_req;

         IF c_linked_req_dists%found THEN
             l_req_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_linked_req.gl_encumbered_date, l_po_dists_po.sob_id);

             -- If the requisition GL date is already in the current year then
             -- do not update the requisition
             IF l_req_gl_fiscal_year >= l_fiscal_year THEN
                l_passed_validation := FALSE;
             END IF;

             --If validations passed, then roll forward the date

             IF l_passed_validation THEN
                UPDATE po_req_distributions
                SET gl_encumbered_date = p_action_date
                WHERE distribution_id = l_linked_req.distribution_id;
             END IF;

         --Continue processing if no linked requsition distribution found.

         ELSE

             Open c_req_dists(l_po_dists_po.req_distribution_id);
             Fetch c_req_dists into l_req_gl_date;
             Close c_req_dists;
             l_req_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_req_gl_date, l_po_dists_po.sob_id);
             IF l_req_gl_fiscal_year >= l_fiscal_year THEN
                l_passed_validation := FALSE;
             END IF;

             --If validation passed, then roll forward date.

             IF l_passed_validation THEN
                UPDATE po_req_distributions
                SET gl_encumbered_date = p_action_date
                WHERE distribution_id = l_po_dists_po.req_distribution_id;
             END IF;

         END IF; --req_dists%found

         close c_linked_req_dists;

       END IF; --validation

       END LOOP; --FOR l_po_dists

   END IF; --p_document_subtype IN (PLANNED, STANDARD)

 ELSIF p_document_type LIKE 'REL%'
 AND NVL(l_purch_encumbrance_flag,'N')='Y'  THEN

    IF p_document_sub_type = 'SCHEDULED' THEN

       --Loop release distributions
       FOR l_po_dists_sch_rel IN c_po_dists_sch_rel
       LOOP

           --Initialize validation Flag

           l_passed_validation := TRUE;

           --Determine Fiscal Year of GL Date of Release Distribution

           l_rel_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_po_dists_sch_rel.rel_gl_date, l_po_dists_sch_rel.sob_id);

           IF l_fiscal_year <> l_rel_gl_fiscal_year THEN
              l_passed_validation := FALSE;
           END IF;

           IF l_passed_validation THEN

              --Determine fiscal year of PO Distribution GL Date. If greater or equal to fiscal year
              --then fail.

              Open c_po_dists(l_po_dists_sch_rel.source_distribution_id);
              Fetch c_po_dists into l_po_gl_date;
              Close c_po_dists;

              l_po_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_po_gl_date, l_po_dists_sch_rel.sob_id);

              IF l_po_gl_fiscal_year >= l_fiscal_year THEN
                 l_passed_validation := FALSE;
              END IF;

           END IF;

           --If all validations pass then PO dist GL Dates require rolling forward

           IF l_passed_validation THEN
              UPDATE po_distributions
              SET    gl_encumbered_date = p_action_date
              WHERE  po_distribution_id = l_po_dists_sch_rel.source_distribution_id;
           END IF;

       END LOOP;

    ELSIF p_document_sub_type = 'BLANKET' THEN

          --Loop through Release Distributions
          FOR l_po_dists_bla_rel IN c_po_dists_bla_rel
          LOOP

              --Initialize validation flag

              l_passed_validation := TRUE;

              --Determine Fiscal Year of GL Date of Release Distributions. If different then fail
              --validation.

              l_rel_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_po_dists_bla_rel.rel_gl_date, l_po_dists_bla_rel.sob_id);

              IF l_fiscal_year <> l_rel_gl_fiscal_year THEN
                 l_passed_validation := FALSE;
              END IF;

              IF l_passed_validation THEN

                 --Check to see if linked requsition distribution exists

                 Open c_linked_req_dists(l_po_dists_bla_rel.req_distribution_id);
                 Fetch c_linked_req_dists into l_linked_req;

                 IF c_linked_req_dists%found THEN

                    l_req_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_linked_req.gl_encumbered_date, l_po_dists_bla_rel.sob_id);

                    IF l_req_gl_fiscal_year >= l_fiscal_year THEN
                       l_passed_validation := FALSE;
                    END IF;

                    --If all validations pass, then roll forward linked requisition distribution gl_date

                    IF l_passed_validation THEN
                       UPDATE po_req_distributions
                       SET    gl_encumbered_date = p_action_date
                       WHERE  distribution_id    = l_linked_req.distribution_id;
                    END IF;

                 --If no linked requisition distributions exist then continue

                 ELSE --c_linked_req_dists%found

                    --determine fiscal year of requsition distribution GL date. If greater or equal to
                    --fiscal year then fail validation

                    Open c_req_dists(l_po_dists_bla_rel.req_distribution_id);
                    Fetch c_req_dists into l_req_gl_date;
                    Close c_req_dists;

                    l_req_gl_fiscal_year := igc_cbc_po_grp.get_fiscal_year(l_req_gl_date, l_po_dists_bla_rel.sob_id);

                    IF l_req_gl_fiscal_year >= l_fiscal_year THEN
                       l_passed_validation := FALSE;
                    END IF;

                    -- If all validations pass, then roll forward requisition distribution gl date
                    IF l_passed_validation THEN
                       UPDATE po_req_distributions
                       SET gl_encumbered_date = p_action_date
                       WHERE distribution_id = l_po_dists_bla_rel.req_distribution_id;
                    END IF;

                 END IF; --linked req distributions found

             END IF; --passed validation

          END LOOP; --For l_po_dists_bla_rel

    END IF; --p_document_subtype = 'BLANKET'

 END IF; --p_document_type = 'REL'

 IF FND_API.To_Boolean(p_commit)
 THEN
     COMMIT WORK ;
 END IF ;

*/ -- Entire procedure commeted out.

 FND_MSG_PUB.Count_And_Get
                         (   p_count     =>     x_msg_count,
                             p_data      =>     x_msg_data
                         );

 EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                         FND_MSG_PUB.Count_And_Get
                         (   p_count     =>     x_msg_count,
                             p_data      =>     x_msg_data
                         );

 WHEN OTHERS THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                 IF FND_MSG_PUB.Check_Msg_Level
                 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                 THEN
                 FND_MSG_PUB.Add_Exc_Msg
                         (       G_PKG_NAME,
                                 l_api_name
                          );
                 END IF;
                 FND_MSG_PUB.Count_And_Get
                 (   p_count     =>     x_msg_count,
                     p_data      =>     x_msg_data
                 );

END gl_date_roll_forward ;

END igc_cbc_po_grp;


/
