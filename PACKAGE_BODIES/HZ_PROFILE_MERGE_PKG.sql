--------------------------------------------------------
--  DDL for Package Body HZ_PROFILE_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PROFILE_MERGE_PKG" AS
/*$Header: ARHMPROB.pls 120.1 2005/06/16 21:12:38 jhuang noship $ */

/* Private Routine Spec*/
  FUNCTION has_to_prof_this_currency
  ( p_to_profile_id      IN NUMBER,
    p_currency_code      IN VARCHAR2)
  RETURN NUMBER;

  PROCEDURE do_profile_merge
  ( p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
    x_to_id         IN OUT  NOCOPY NUMBER,
    p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
    p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
    x_return_status IN OUT  NOCOPY VARCHAR2);

  PROCEDURE do_profile_amt_transf
  (p_from_profile_id  IN NUMBER,
   p_to_profile_id    IN NUMBER,
   x_return_status    IN OUT NOCOPY VARCHAR2);
/**********/


  PROCEDURE profile_merge(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT	NOCOPY NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	IN	NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status OUT          NOCOPY VARCHAR2)
  IS
    l_to_id     NUMBER;
  BEGIN

   IF (x_to_id IS NULL) THEN
      l_to_id := FND_API.G_MISS_NUM;
   ELSE
      l_to_id := x_to_id;
   END IF;

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   hz_merge_pkg.check_params(
        p_entity_name      => 'HZ_CUSTOMER_PROFILES',
        p_from_id          => p_from_id,
        p_to_id            => x_to_id,
        p_from_fk_id       => p_from_fk_id,
        p_to_fk_id         => p_to_fk_id,
        p_par_entity_name  => 'HZ_PARTIES',
	p_proc_name        => 'HZ_MERGE_PKG.party_profile_merge',
	p_exp_ent_name     => 'HZ_CUSTOMER_PROFILES',
        p_exp_par_ent_name => 'HZ_PARTIES',
        p_pk_column        => 'CUST_ACCOUNT_PROFILE_ID',
	p_par_pk_column	   => 'PARTY_ID',
	x_return_status    => x_return_status );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     do_profile_merge
     ( p_from_id       => p_from_id,
       x_to_id         => x_to_id,
       p_from_fk_id    => p_from_fk_id,
       p_to_fk_id      => p_to_fk_id,
       x_return_status => x_return_status);

   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END;

  FUNCTION has_to_prof_this_currency
  ( p_to_profile_id      IN NUMBER,
    p_currency_code      IN VARCHAR2)
  RETURN NUMBER
  IS
    CURSOR c1 IS
    SELECT cust_acct_profile_amt_id,
           cust_account_profile_id,
           currency_code
      FROM hz_cust_profile_amts
     WHERE cust_account_profile_id = p_to_profile_id;
    l_rec  c1%ROWTYPE;
    Ret    NUMBER := FND_API.G_MISS_NUM;
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 INTO l_rec;
      EXIT WHEN c1%NOTFOUND;
      IF p_currency_code = l_rec.currency_code THEN
         ret := l_rec.cust_acct_profile_amt_id;
         EXIT;
      END IF;
    END LOOP;
    CLOSE c1;
    RETURN ret;
  END;

  PROCEDURE do_profile_amt_transf
  (p_from_profile_id  IN NUMBER,
   p_to_profile_id    IN NUMBER,
   x_return_status    IN OUT NOCOPY VARCHAR2)
  IS

    CURSOR c1 IS
    SELECT cust_acct_profile_amt_id,
           cust_account_profile_id,
           currency_code
      FROM hz_cust_profile_amts
     WHERE cust_account_profile_id = p_from_profile_id;
    l_rec c1%ROWTYPE;
    l_to_prof_amt_id  NUMBER;
    l_temp            NUMBER;

  BEGIN

    OPEN c1;
    LOOP
      FETCH c1 INTO l_rec;
      EXIT WHEN c1%NOTFOUND;

      l_to_prof_amt_id := has_to_prof_this_currency
                          ( p_to_profile_id      => p_to_profile_id,
                            p_currency_code      => l_rec.currency_code);

      IF l_to_prof_amt_id = FND_API.G_MISS_NUM THEN

         UPDATE hz_cust_profile_amts
            SET cust_account_profile_id = p_to_profile_id,
                last_update_date = hz_utility_pub.last_update_date,
                last_updated_by = hz_utility_pub.user_id,
                last_update_login = hz_utility_pub.last_update_login,
                request_id =  hz_utility_pub.request_id,
                program_application_id = hz_utility_pub.program_application_id,
                program_id = hz_utility_pub.program_id,
                program_update_date = sysdate
          WHERE cust_acct_profile_amt_id = l_rec.cust_acct_profile_amt_id;

       END IF;
     END LOOP;
     CLOSE c1;

  EXCEPTION

    WHEN OTHERS THEN
      IF c1%ISOPEN THEN
        CLOSE c1;
      END IF;
      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END;


  PROCEDURE do_profile_merge
  ( p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
    x_to_id         IN OUT  NOCOPY NUMBER,
    p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
    p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
    x_return_status IN OUT  NOCOPY VARCHAR2)
  IS

    CURSOR c_from_profile
    IS
    SELECT cust_account_profile_id,
           cust_account_id,
           party_id,
           site_use_id,
           status
      FROM hz_customer_profiles
     WHERE cust_account_profile_id = p_from_id;

    CURSOR c_to_party_profile
    IS
    SELECT cust_account_profile_id,
           cust_account_id,
           party_id,
           site_use_id
      FROM hz_customer_profiles
     WHERE party_id        = p_to_fk_id
       AND cust_account_id = -1;

    l_from_rec     c_from_profile%ROWTYPE;
    l_to_party_rec c_to_party_profile%ROWTYPE;

  BEGIN

    OPEN c_from_profile;
    LOOP
      FETCH c_from_profile INTO l_from_rec;
      EXIT WHEN c_from_profile%NOTFOUND;

      IF      l_from_rec.site_use_id IS NOT NULL THEN

         -- Site Use Level Stuff
         -- Transfert
         UPDATE hz_customer_profiles
            SET party_id          = p_to_fk_id,
                last_update_date  = hz_utility_pub.last_update_date,
                last_updated_by   = hz_utility_pub.user_id,
                last_update_login = hz_utility_pub.last_update_login,
                request_id        =  hz_utility_pub.request_id,
                program_application_id = hz_utility_pub.program_application_id,
                program_id        = hz_utility_pub.program_id,
                program_update_date = sysdate
          WHERE cust_account_profile_id = l_from_rec.cust_account_profile_id;


      ELSIF   l_from_rec.cust_account_id <> -1 THEN

         -- Account Level Stuff
         -- Transfert
         UPDATE hz_customer_profiles
            SET party_id          = p_to_fk_id,
                last_update_date  = hz_utility_pub.last_update_date,
                last_updated_by   = hz_utility_pub.user_id,
                last_update_login = hz_utility_pub.last_update_login,
                request_id        =  hz_utility_pub.request_id,
                program_application_id = hz_utility_pub.program_application_id,
                program_id        = hz_utility_pub.program_id,
                program_update_date = sysdate
          WHERE cust_account_profile_id = l_from_rec.cust_account_profile_id;

      ELSE
         -- Party Level Stuff
         -- Merge or Transfert

         OPEN c_to_party_profile;
         FETCH c_to_party_profile INTO l_to_party_rec;
         IF c_to_party_profile%NOTFOUND THEN

           -- Transfert Party Profile
           UPDATE hz_customer_profiles
              SET party_id          = p_to_fk_id,
                  last_update_date  = hz_utility_pub.last_update_date,
                  last_updated_by   = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  request_id        =  hz_utility_pub.request_id,
                  program_application_id = hz_utility_pub.program_application_id,
                  program_id        = hz_utility_pub.program_id,
                  program_update_date = sysdate
            WHERE cust_account_profile_id = l_from_rec.cust_account_profile_id;

          ELSE
           -- Merge Party Profile
           x_to_id     :=  l_to_party_rec.cust_account_profile_id;

           IF l_from_rec.status  = 'A' OR l_from_rec.status IS NULL THEN
              do_profile_amt_transf(p_from_id, x_to_id, x_return_status );
           END IF;

           UPDATE hz_customer_profiles
              SET status = 'M',
                  last_update_date  = hz_utility_pub.last_update_date,
                  last_updated_by   = hz_utility_pub.user_id,
                  last_update_login = hz_utility_pub.last_update_login,
                  request_id        =  hz_utility_pub.request_id,
                  program_application_id = hz_utility_pub.program_application_id,
                  program_id        = hz_utility_pub.program_id,
                  program_update_date = sysdate
            WHERE cust_account_profile_id = l_from_rec.cust_account_profile_id;

         END IF;
         CLOSE c_to_party_profile;

      END IF;

    END LOOP;

    CLOSE c_from_profile;

  EXCEPTION

    WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END;

END;

/
