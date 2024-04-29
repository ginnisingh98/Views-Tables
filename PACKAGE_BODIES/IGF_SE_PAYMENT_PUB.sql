--------------------------------------------------------
--  DDL for Package Body IGF_SE_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SE_PAYMENT_PUB" AS
/* $Header: IGFSE02B.pls 120.0 2005/06/01 15:00:56 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: igf_se_payment_pub                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 |                                                                       |
 |                                                                       |
 | HISTORY                                                               |
 | Who       When         What                                           |
 *=======================================================================*/

  /**  private procedure
    *  forward declaration here
    */
  PROCEDURE do_create_payment(
    p_payment_record IN payment_rec_type,
    x_transaction_id OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
  );

  /**  main procedure create_payment
    *
    */
  PROCEDURE create_payment(
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_payment_rec IN payment_rec_type,
    x_transaction_id OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2
  ) IS
  BEGIN

    -- establish standard save point
    SAVEPOINT create_payment;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call local procedure to create the payment record
    do_create_payment(p_payment_record => p_payment_rec,
                      x_transaction_id => x_transaction_id,
                      x_return_status => x_return_status);

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_payment;

      x_return_status := FND_API.G_RET_STS_ERROR;

      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_payment;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SE_PAYMENT_PUB '||SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded                    => fnd_api.g_false,
        p_count                      => x_msg_count,
        p_data                       => x_msg_data);

  END create_payment;

  PROCEDURE do_create_payment(p_payment_record payment_rec_type,
                              x_transaction_id OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2
                             ) IS

    -- cursor to check if the existing payroll id, person id and authorization id
    -- is already existing in the system. this cursor will have FTS ?
    CURSOR c_check_payroll (p_payroll_id igf_se_payment.payroll_id%TYPE,
                            p_auth_id igf_se_auth.auth_id%TYPE,
                            p_person_id hz_parties.party_id%TYPE) IS
      SELECT ROWID, p.*
        FROM igf_se_payment p
       WHERE p.payroll_id = p_payroll_id
         AND p.auth_id = p_auth_id
         AND p.person_id = p_person_id;

    -- cursor to get the fund id from the supplied parameters
    CURSOR c_get_fund_id (p_auth_id igf_se_auth.auth_id%TYPE,
                          p_person_id hz_parties.party_id%TYPE) IS
      SELECT se.fund_id
        FROM igf_se_auth se
       WHERE se.flag = 'A'
         AND se.person_id = p_person_id
         AND se.auth_id = p_auth_id;

    c_check_payroll_rec  c_check_payroll%ROWTYPE;
    l_fund_id igf_aw_award_all.fund_id%TYPE;
    l_rowid VARCHAR2(25);
    l_transaction_id igf_se_payment.transaction_id%TYPE;

    CURSOR c_pers_num(
                      cp_person_id hz_parties.party_id%TYPE
                     ) IS
      SELECT party_number
        FROM hz_parties
       WHERE party_id = cp_person_id;
    l_pers_num    hz_parties.party_number%TYPE;

  BEGIN
    l_fund_id := NULL;
    l_transaction_id := NULL;

    -- begin mandatory validations
    -- a. payroll_id cannot be null. this validation is placed in the api
    --    and not in the tbh as payroll id from ui is not mandatory
    IF(p_payment_record.payroll_id IS NULL)THEN
      fnd_message.set_name('IGF','IGF_SE_PAYROLL_ID_NULL');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check if the payroll id is already existing in the system, if so,
    -- that payment information record should be updated, else a new payment
    -- record has to be created. payroll date, paid amount, organization unit name and source
    -- can be updated.
    OPEN c_check_payroll(p_payment_record.payroll_id, p_payment_record.authorization_id, p_payment_record.person_id);
    FETCH c_check_payroll INTO c_check_payroll_rec; CLOSE c_check_payroll;
    IF(c_check_payroll_rec.transaction_id IS NOT NULL)THEN
      -- call to update the new payment information
      igf_se_payment_pkg.update_row(
                                    x_rowid               => c_check_payroll_rec.rowid,
                                    x_transaction_id      => c_check_payroll_rec.transaction_id,
                                    x_payroll_id          => c_check_payroll_rec.payroll_id,
                                    x_payroll_date        => p_payment_record.payroll_date,
                                    x_auth_id             => c_check_payroll_rec.auth_id,
                                    x_person_id           => c_check_payroll_rec.person_id,
                                    x_fund_id             => c_check_payroll_rec.fund_id,
                                    x_paid_amount         => p_payment_record.paid_amount,
                                    x_org_unit_cd         => p_payment_record.organization_unit_name,
                                    x_source              => p_payment_record.source,
                                    x_mode                => 'R'
                                   );
    ELSE
      --derive the fund id value before insert
      OPEN c_get_fund_id(p_payment_record.authorization_id, p_payment_record.person_id);
      FETCH c_get_fund_id INTO l_fund_id; CLOSE c_get_fund_id;
      IF(l_fund_id IS NOT NULL)THEN
        -- call to record the existing payment information

        igf_se_payment_pkg.insert_row(
                                      x_rowid             => l_rowid,
                                      x_transaction_id    => l_transaction_id,
                                      x_payroll_id        => p_payment_record.payroll_id,
                                      x_payroll_date      => p_payment_record.payroll_date,
                                      x_auth_id           => p_payment_record.authorization_id,
                                      x_person_id         => p_payment_record.person_id,
                                      x_fund_id           => l_fund_id,
                                      x_paid_amount       => p_payment_record.paid_amount,
                                      x_org_unit_cd       => p_payment_record.organization_unit_name,
                                      x_source            => p_payment_record.source,
                                      x_mode              => 'R'
                                     );
        IF(l_transaction_id IS NULL)THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          x_transaction_id := l_transaction_id;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF; -- end for transaction id is null condition
      ELSE
        fnd_message.set_name('IGF','IGF_SE_NO_VALID_FUND');

        l_pers_num := NULL;
        OPEN c_pers_num(p_payment_record.person_id);
        FETCH c_pers_num INTO l_pers_num;
        CLOSE c_pers_num;
        fnd_message.set_token('PERSON_NUM',l_pers_num);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;  -- end of payroll exists check
  END do_create_payment;

END igf_se_payment_pub;

/
