--------------------------------------------------------
--  DDL for Package Body PN_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_DISTRIBUTIONS_PKG" 
-- $Header: PNTDISTB.pls 120.11 2006/03/07 04:26:27 appldev noship $

AS

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 21-JUN-05 sdmahesh o Bug 4284035 - Replaced pn_distributions with _ALL table.
-- 01-DEC-05 sdmahesh o Modified the legal_entity_id update logic
-- 27-dec-05 piagrawa o Bug#4911362 - updated to make sure that l_org_id is not
--                      null before being inserted into the table.
-- 07-MAR-06 Kiran    o Bug # 5081563 - changed the query to get line #
-------------------------------------------------------------------------------
PROCEDURE insert_row (
      x_rowid                IN OUT   NOCOPY VARCHAR2
     ,x_distribution_id      IN OUT   NOCOPY NUMBER
     ,x_account_id           IN       NUMBER
     ,x_payment_term_id      IN       NUMBER
     ,x_term_template_id     IN       NUMBER
     ,x_account_class        IN       VARCHAR2
     ,x_percentage           IN       NUMBER
     ,x_line_number          IN OUT   NOCOPY NUMBER
     ,x_last_update_date     IN       DATE
     ,x_last_updated_by      IN       NUMBER
     ,x_creation_date        IN       DATE
     ,x_created_by           IN       NUMBER
     ,x_last_update_login    IN       NUMBER
     ,x_attribute_category   IN       VARCHAR2
     ,x_attribute1           IN       VARCHAR2
     ,x_attribute2           IN       VARCHAR2
     ,x_attribute3           IN       VARCHAR2
     ,x_attribute4           IN       VARCHAR2
     ,x_attribute5           IN       VARCHAR2
     ,x_attribute6           IN       VARCHAR2
     ,x_attribute7           IN       VARCHAR2
     ,x_attribute8           IN       VARCHAR2
     ,x_attribute9           IN       VARCHAR2
     ,x_attribute10          IN       VARCHAR2
     ,x_attribute11          IN       VARCHAR2
     ,x_attribute12          IN       VARCHAR2
     ,x_attribute13          IN       VARCHAR2
     ,x_attribute14          IN       VARCHAR2
     ,x_attribute15          IN       VARCHAR2
     ,x_org_id               IN       NUMBER
   )
   IS
   l_return_status   VARCHAR2 (30) := NULL;
   l_rowid           VARCHAR2 (18) := NULL;
   l_org_id          pn_distributions_all.org_id%TYPE ;
   l_vendor_site_id  NUMBER;
   l_term_le_ID      NUMBER;

   l_count           NUMBER;

   CURSOR csr_vendor_info IS
      SELECT term.vendor_site_id AS vendor_site_id,
             term.legal_entity_id AS legal_entity_id,
             term.org_id AS org_id
      FROM  pn_payment_terms_all term
      WHERE term.payment_term_id = x_payment_term_id;

   l_legal_entity_id pn_payment_terms.legal_entity_id%TYPE;

   CURSOR term_org (p_term_ID IN NUMBER) IS
      SELECT org_ID
      FROM pn_payment_terms_all
      WHERE payment_term_id = p_term_ID;

   CURSOR template_org (p_template_ID IN NUMBER) IS
      SELECT org_ID
      FROM pn_term_templates_all
      WHERE term_template_id = p_template_ID;

   BEGIN

-- PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.insert_row (+)');

      /* handle the le stamping */
      FOR rec IN csr_vendor_info LOOP
        l_org_id          := rec.org_id;
        l_vendor_site_id  := rec.vendor_site_id;
        l_term_le_ID      := rec.legal_entity_id;
      END LOOP;

      SELECT count(*) INTO l_count
      FROM   pn_distributions_all pd
      WHERE  pd.payment_term_id = x_payment_term_id;

      IF pn_r12_util_pkg.is_r12  AND (l_count < 1)THEN
         l_legal_entity_id :=
               pn_r12_util_pkg.get_le_for_ap(
                                             p_code_combination_id => x_account_id
                                             ,p_location_id        => l_vendor_site_id
                                             ,p_org_id             => l_org_id
                                            );
         IF l_term_le_ID <> l_legal_entity_id THEN
            UPDATE pn_payment_terms_all
            SET    legal_entity_id   = l_legal_entity_id,
                   last_update_date  = x_last_update_date,
                   last_updated_by   = x_last_updated_by,
                   last_update_login = x_last_update_login
            WHERE payment_term_id = x_payment_term_id;
         END IF;
      END IF;

      IF (x_distribution_id IS NULL)
      THEN
         SELECT pn_distributions_s.NEXTVAL
           INTO x_distribution_id
           FROM DUAL;
      END IF;

      /* make sure the org ID is not null */
      IF x_org_id IS NOT NULL THEN
         l_org_id := x_org_id;
      ELSE
         IF x_payment_term_id IS NOT NULL THEN
            FOR rec IN term_org(x_payment_term_id) LOOP
               l_org_id := rec.org_id;
            END LOOP;

         ELSIF x_term_template_id IS NOT NULL THEN
             FOR rec IN template_org(x_term_template_id) LOOP
               l_org_id := rec.org_id;
            END LOOP;

         END IF;

      END IF;

      /* get the line # */
      IF x_line_number IS NULL THEN

         IF x_payment_term_id IS NOT NULL THEN

            SELECT NVL(MAX(line_number),0) + 1
              INTO x_line_number
              FROM pn_distributions_all
             WHERE payment_term_id = x_payment_term_id;

         ELSIF x_term_template_id IS NOT NULL THEN

            SELECT NVL(MAX(line_number),0) + 1
              INTO x_line_number
              FROM pn_distributions_all
             WHERE term_template_id = x_term_template_id;

         END IF;

      END IF;

      INSERT INTO pn_distributions_all
        (distribution_id
        ,account_id
        ,payment_term_id
        ,term_template_id
        ,account_class
        ,percentage
        ,line_number
        ,last_update_date
        ,last_updated_by
        ,creation_date
        ,created_by
        ,last_update_login
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,org_id
        )
      VALUES (x_distribution_id
             ,x_account_id
             ,x_payment_term_id
             ,x_term_template_id
             ,x_account_class
             ,x_percentage
             ,x_line_number
             ,x_last_update_date
             ,x_last_updated_by
             ,x_creation_date
             ,x_created_by
             ,x_last_update_login
             ,x_attribute_category
             ,x_attribute1
             ,x_attribute2
             ,x_attribute3
             ,x_attribute4
             ,x_attribute5
             ,x_attribute6
             ,x_attribute7
             ,x_attribute8
             ,x_attribute9
             ,x_attribute10
             ,x_attribute11
             ,x_attribute12
             ,x_attribute13
             ,x_attribute14
             ,x_attribute15
             ,l_org_id
             );


      IF (SQL%NOTFOUND) THEN

         RAISE NO_DATA_FOUND;

      END IF;


--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.insert_row (-)');
   END insert_row;

-------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_distributions with _ALL table
--                       and changed the where condition.
-- 01-DEC-05  sdmahesh o Modified the legal_entity_id update logic
-------------------------------------------------------------------------------
PROCEDURE update_row (
      x_rowid                IN   VARCHAR2
     ,x_distribution_id      IN   NUMBER
     ,x_account_id           IN   NUMBER
     ,x_payment_term_id      IN   NUMBER
     ,x_term_template_id     IN   NUMBER
     ,x_account_class        IN   VARCHAR2
     ,x_percentage           IN   NUMBER
     ,x_line_number          IN   NUMBER
     ,x_last_update_date     IN   DATE
     ,x_last_updated_by      IN   NUMBER
     ,x_last_update_login    IN   NUMBER
     ,x_attribute_category   IN   VARCHAR2
     ,x_attribute1           IN   VARCHAR2
     ,x_attribute2           IN   VARCHAR2
     ,x_attribute3           IN   VARCHAR2
     ,x_attribute4           IN   VARCHAR2
     ,x_attribute5           IN   VARCHAR2
     ,x_attribute6           IN   VARCHAR2
     ,x_attribute7           IN   VARCHAR2
     ,x_attribute8           IN   VARCHAR2
     ,x_attribute9           IN   VARCHAR2
     ,x_attribute10          IN   VARCHAR2
     ,x_attribute11          IN   VARCHAR2
     ,x_attribute12          IN   VARCHAR2
     ,x_attribute13          IN   VARCHAR2
     ,x_attribute14          IN   VARCHAR2
     ,x_attribute15          IN   VARCHAR2
     ,x_lease_change_id      IN   NUMBER
   )
   IS

   CURSOR csr_vendor_info IS
    SELECT term.vendor_site_id AS vendor_site_id,
           term.legal_entity_id AS legal_entity_id,
           term.org_id          AS org_id
    FROM  pn_payment_terms_all term
    WHERE  term.payment_term_id = x_payment_term_id;

   l_legal_entity_id pn_payment_terms.legal_entity_id%TYPE;
   l_return_status   VARCHAR2 (30) := NULL;
   l_count           NUMBER;
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.update_row (+)');

      SELECT count(*) INTO l_count
      FROM   pn_distributions_all dist,
             pn_payment_terms_all term
      WHERE  dist.payment_term_id  = term.payment_term_id
      AND    term.payment_term_id  = x_payment_term_id
      AND    dist.distribution_id  <> x_distribution_id;

      IF pn_r12_util_pkg.is_r12  AND (l_count < 1)THEN
        FOR csr_vendor_info_rec IN csr_vendor_info LOOP
           l_legal_entity_id :=
           pn_r12_util_pkg.get_le_for_ap(
                                         p_code_combination_id => x_account_id
                                         ,p_location_id        => csr_vendor_info_rec.vendor_site_id
                                         ,p_org_id             => csr_vendor_info_rec.org_id
                                        );
           IF csr_vendor_info_rec.legal_entity_id <> l_legal_entity_id THEN
              UPDATE pn_payment_terms_all
              SET    legal_entity_id   = l_legal_entity_id,
                     last_update_date  = x_last_update_date,
                     last_updated_by   = x_last_updated_by,
                     last_update_login = x_last_update_login
              WHERE payment_term_id = x_payment_term_id;
           END IF;
        END LOOP;
      END IF;

      UPDATE pn_distributions_all
         SET account_id = x_account_id
            ,payment_term_id = x_payment_term_id
            ,term_template_id = x_term_template_id
            ,account_class = x_account_class
            ,percentage = x_percentage
            ,line_number = x_line_number
            ,last_update_date = x_last_update_date
            ,last_updated_by = x_last_updated_by
            ,last_update_login = x_last_update_login
            ,attribute_category = x_attribute_category
            ,attribute1 = x_attribute1
            ,attribute2 = x_attribute2
            ,attribute3 = x_attribute3
            ,attribute4 = x_attribute4
            ,attribute5 = x_attribute5
            ,attribute6 = x_attribute6
            ,attribute7 = x_attribute7
            ,attribute8 = x_attribute8
            ,attribute9 = x_attribute9
            ,attribute10 = x_attribute10
            ,attribute11 = x_attribute11
            ,attribute12 = x_attribute12
            ,attribute13 = x_attribute13
            ,attribute14 = x_attribute14
            ,attribute15 = x_attribute15
       WHERE distribution_id = x_distribution_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF x_lease_change_id IS NOT NULL THEN
         UPDATE pn_payment_terms_all
            SET lease_change_id = x_lease_change_id
         WHERE payment_term_id = x_payment_term_id;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.update_row (-)');
 END update_row;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_distributions with _ALL table.
-------------------------------------------------------------------------------
   PROCEDURE lock_row (
      x_rowid                IN   VARCHAR2
     ,x_distribution_id      IN   NUMBER
     ,x_account_id           IN   NUMBER
     ,x_payment_term_id      IN   NUMBER
     ,x_term_template_id     IN   NUMBER
     ,x_account_class        IN   VARCHAR2
     ,x_percentage           IN   NUMBER
     ,x_line_number          IN   NUMBER
     ,x_attribute_category   IN   VARCHAR2
     ,x_attribute1           IN   VARCHAR2
     ,x_attribute2           IN   VARCHAR2
     ,x_attribute3           IN   VARCHAR2
     ,x_attribute4           IN   VARCHAR2
     ,x_attribute5           IN   VARCHAR2
     ,x_attribute6           IN   VARCHAR2
     ,x_attribute7           IN   VARCHAR2
     ,x_attribute8           IN   VARCHAR2
     ,x_attribute9           IN   VARCHAR2
     ,x_attribute10          IN   VARCHAR2
     ,x_attribute11          IN   VARCHAR2
     ,x_attribute12          IN   VARCHAR2
     ,x_attribute13          IN   VARCHAR2
     ,x_attribute14          IN   VARCHAR2
     ,x_attribute15          IN   VARCHAR2
   )
   IS
      CURSOR c1
      IS
         SELECT        *
         FROM pn_distributions_all
         WHERE distribution_id = x_distribution_id
         FOR UPDATE OF distribution_id NOWAIT;

      tlinfo   c1%ROWTYPE;
   BEGIN

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.lock_row (+)');
      OPEN c1;
      FETCH c1 INTO tlinfo;

      IF (c1%NOTFOUND)
      THEN
         CLOSE c1;
         RETURN;
      END IF;

      CLOSE c1;

          IF NOT (tlinfo.distribution_id = x_distribution_id) THEN
             pn_var_rent_pkg.lock_row_exception('DISTRIBUTION_ID',tlinfo.distribution_id);
          END IF;
          IF NOT (tlinfo.account_id = x_account_id) THEN
             pn_var_rent_pkg.lock_row_exception('ACCOUNT_ID',tlinfo.account_id);
          END IF;
          IF NOT (   (tlinfo.payment_term_id = x_payment_term_id)
               OR ((tlinfo.payment_term_id IS NULL) AND x_payment_term_id IS NULL)
              ) THEN
             pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_ID',tlinfo.payment_term_id);
          END IF;
          IF NOT (   (tlinfo.term_template_id = x_term_template_id)
               OR ((tlinfo.term_template_id IS NULL) AND x_term_template_id IS NULL)
              ) THEN
             pn_var_rent_pkg.lock_row_exception('TERM_TEMPLATE_ID',tlinfo.term_template_id);
          END IF;
          IF NOT (   (tlinfo.percentage = x_percentage)
               OR ((tlinfo.percentage IS NULL) AND x_percentage IS NULL)
              ) THEN
             pn_var_rent_pkg.lock_row_exception('PERCENTAGE',tlinfo.percentage);
          END IF;
          IF NOT (   (tlinfo.line_number = x_line_number)
               OR ((tlinfo.line_number IS NULL) AND x_line_number IS NULL)
              ) THEN
             pn_var_rent_pkg.lock_row_exception('LINE_NUMBER',tlinfo.line_number);
          END IF;

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.lock_row (-)');
   END lock_row;


-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_distributions with _ALL table.
-------------------------------------------------------------------------------
   PROCEDURE delete_row (x_rowid IN VARCHAR2)
   IS

    l_term_id         pn_payment_terms.payment_term_id%TYPE;
    l_legal_entity_id pn_payment_terms.legal_entity_id%TYPE;

    CURSOR get_term_data(p_term_id pn_payment_terms.payment_term_id%TYPE) IS
     SELECT term.vendor_site_id,
            term.legal_entity_id,
            term.org_id,
            dist.account_id
       FROM pn_payment_terms_all term,
            pn_distributions_all dist
      WHERE term.payment_term_id = dist.payment_term_id (+)
        AND term.payment_term_id = p_term_id
        AND rownum < 2;

   BEGIN

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.delete_row (+)');
      DELETE FROM pn_distributions_all
            WHERE ROWID = x_rowid
        RETURNING payment_term_id INTO l_term_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF pn_r12_util_pkg.is_r12 THEN
        FOR chk_dist_rec IN get_term_data (l_term_id) LOOP
          IF chk_dist_rec.account_id IS NULL AND
             chk_dist_rec.vendor_site_id IS NOT NULL THEN

             l_legal_entity_id :=
               pn_r12_util_pkg.get_le_for_ap(
                 p_code_combination_id => null
                ,p_location_id         => chk_dist_rec.vendor_site_id
                ,p_org_id              => chk_dist_rec.org_id
               );

             IF NOT ((chk_dist_rec.legal_entity_id = l_legal_entity_id) OR
                     (chk_dist_rec.legal_entity_id IS NULL AND l_legal_entity_id IS NULL)) THEN
                UPDATE pn_payment_terms
                   SET legal_entity_id   = l_legal_entity_id,
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE payment_term_id = l_term_id;
             END IF;
           END IF;
        END LOOP;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.delete_row (-)');
   END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overloaded this procedure to take PK as In parameter
-- HISTORY      :
-- 04-JUL-05  piagrawa   o Bug 4284035 - Created
-------------------------------------------------------------------------------
   PROCEDURE delete_row (x_distribution_id IN NUMBER)
   IS

    l_term_id         pn_payment_terms.payment_term_id%TYPE;
    l_legal_entity_id pn_payment_terms.legal_entity_id%TYPE;

    CURSOR get_term_data(p_term_id pn_payment_terms.payment_term_id%TYPE) IS
     SELECT term.vendor_site_id,
            term.legal_entity_id,
            term.org_id,
            dist.account_id
       FROM pn_payment_terms_all term,
            pn_distributions_all dist
      WHERE term.payment_term_id = dist.payment_term_id (+)
        AND term.payment_term_id = p_term_id
        AND rownum < 2;

   BEGIN

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.delete_row (+)');
      DELETE FROM pn_distributions_all
            WHERE  distribution_id = x_distribution_id
        RETURNING payment_term_id INTO l_term_id;

      IF (SQL%NOTFOUND)
      THEN
         RAISE NO_DATA_FOUND;
      END IF;

      IF pn_r12_util_pkg.is_r12 THEN
        FOR chk_dist_rec IN get_term_data (l_term_id) LOOP
          IF chk_dist_rec.account_id IS NULL AND
             chk_dist_rec.vendor_site_id IS NOT NULL THEN

             l_legal_entity_id :=
               pn_r12_util_pkg.get_le_for_ap(
                 p_code_combination_id => null
                ,p_location_id         => chk_dist_rec.vendor_site_id
                ,p_org_id              => chk_dist_rec.org_id
               );

             IF NOT ((chk_dist_rec.legal_entity_id = l_legal_entity_id) OR
                     (chk_dist_rec.legal_entity_id IS NULL AND l_legal_entity_id IS NULL)) THEN
                UPDATE pn_payment_terms
                   SET legal_entity_id   = l_legal_entity_id,
                       last_update_date  = SYSDATE,
                       last_updated_by   = fnd_global.user_id,
                       last_update_login = fnd_global.login_id
                 WHERE payment_term_id = l_term_id;
             END IF;
           END IF;
        END LOOP;
      END IF;

--PNP_DEBUG_PKG.debug (' PN_DISTRIBUTIONS_PKG.delete_row (-)');
   END delete_row;

END pn_distributions_pkg;

/
