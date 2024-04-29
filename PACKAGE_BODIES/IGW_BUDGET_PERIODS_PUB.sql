--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERIODS_PUB" AS
--$Header: igwpbprb.pls 115.0 2002/12/19 22:43:43 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_BUDGET_PERIODS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Create_Budget_Period
   (
      p_validate_only         IN VARCHAR2,
      p_commit                IN VARCHAR2,
      p_proposal_number       IN VARCHAR2,
      p_version_id            IN NUMBER,
      p_budget_period_id      IN NUMBER,
      p_start_date            IN DATE,
      p_end_date              IN DATE,
      p_total_cost_limit      IN NUMBER,
      p_total_cost            IN NUMBER,
      p_total_direct_cost     IN NUMBER,
      p_total_indirect_cost   IN NUMBER,
      p_cost_sharing_amount   IN NUMBER,
      p_underrecovery_amount  IN NUMBER,
      p_program_income        IN VARCHAR2,
      p_program_income_source IN VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

      l_api_name  CONSTANT  VARCHAR2(30) := 'Create_Budget_Period';
      l_rowid               VARCHAR2(60);
      l_proposal_id         IGW_PROPOSALS_ALL.PROPOSAL_ID%TYPE;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Budget_Period_Pub;

      /*
      **   Initialize Processing
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      Fnd_Msg_Pub.Initialize;

      /*
      **   Verify Mandatory Inputs. Value-Id Conversions.
      */

      IF p_proposal_number IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_PROPOSAL_NUMBER');
         Fnd_Msg_Pub.Add;

      ELSE

         Igw_Utils.Get_Proposal_Id
         (
            p_context_field    => 'PROPOSAL_ID',
            p_check_id_flag    => 'N',
            p_proposal_number  => p_proposal_number,
            p_proposal_id      => l_proposal_id,
            x_proposal_id      => l_proposal_id,
            x_return_status    => x_return_status
         );

      END IF;

      IF p_version_id IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_VERSION_ID');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_budget_period_id IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_BUDGET_PERIOD_ID');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_start_date IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_START_DATE');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_end_date IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_END_DATE');
         Fnd_Msg_Pub.Add;

      END IF;


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      Igw_Budget_Periods_Pvt.Create_Budget_Period
      (
         p_init_msg_list         => Fnd_Api.G_True,
         p_commit                => Fnd_Api.G_False,
         p_validate_only         => p_validate_only,
         p_proposal_id           => l_proposal_id,
         p_version_id            => p_version_id,
         p_budget_period_id      => p_budget_period_id,
         p_start_date            => p_start_date,
         p_end_date              => p_end_date,
         p_total_cost            => p_total_cost,
         p_total_direct_cost     => p_total_direct_cost,
         p_total_indirect_cost   => p_total_indirect_cost,
         p_cost_sharing_amount   => p_cost_sharing_amount,
         p_underrecovery_amount  => p_underrecovery_amount,
         p_total_cost_limit      => p_total_cost_limit,
         p_program_income        => p_program_income,
         p_program_income_source => p_program_income_source,
         x_rowid                 => l_rowid,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Budget_Period_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Budget_Period_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

   END Create_Budget_Period;

   ---------------------------------------------------------------------------

END Igw_Budget_Periods_Pub;

/
