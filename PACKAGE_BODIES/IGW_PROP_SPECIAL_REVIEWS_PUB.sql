--------------------------------------------------------
--  DDL for Package Body IGW_PROP_SPECIAL_REVIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_SPECIAL_REVIEWS_PUB" AS
--$Header: igwprevb.pls 115.0 2002/12/19 22:44:07 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_SPECIAL_REVIEWS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Special_Review
   (
      p_validate_only            IN VARCHAR2,
      p_commit                   IN VARCHAR2,
      p_proposal_number          IN VARCHAR2,
      p_special_review_desc      IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Prop_Special_Review';
      l_rowid                  VARCHAR2(60);
      l_proposal_id            IGW_PROPOSALS_ALL.PROPOSAL_ID%TYPE;
      l_special_review_code    IGW_PROP_SPECIAL_REVIEWS.SPECIAL_REVIEW_CODE%TYPE;
      l_special_review_type    IGW_PROP_SPECIAL_REVIEWS.SPECIAL_REVIEW_TYPE%TYPE;
      l_approval_type_code     IGW_PROP_SPECIAL_REVIEWS.APPROVAL_TYPE_CODE%TYPE;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Prop_Special_Review_Pub;

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

      IF p_special_review_desc IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_SPECIAL_REVIEW_DESC');
         Fnd_Msg_Pub.Add;

      ELSE

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field   => 'SPECIAL_REVIEW_CODE',
            p_check_id_flag   => 'N',
            p_lookup_type     => 'IGW_SPECIAL_REVIEWS',
            p_lookup_meaning  => p_special_review_desc,
            p_lookup_code     => null,
            x_lookup_code     => l_special_review_code,
            x_return_status   => x_return_status
         );

      END IF;

      Igw_Utils.Get_Lookup_Code
      (
         p_context_field   => 'SPECIAL_REVIEW_TYPE',
         p_check_id_flag   => 'N',
         p_lookup_type     => 'IGW_SPECIAL_REVIEW_TYPES',
         p_lookup_meaning  => p_special_review_type_desc,
         p_lookup_code     => null,
         x_lookup_code     => l_special_review_type,
         x_return_status   => x_return_status
      );

      IF p_approval_type_desc IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_APPROVAL_TYPE_DESC');
         Fnd_Msg_Pub.Add;

      ELSE

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field   => 'REVIEW_APPROVAL_TYPE',
            p_check_id_flag   => 'N',
            p_lookup_type     => 'IGW_REVIEW_APPROVAL_TYPES',
            p_lookup_meaning  => p_approval_type_desc,
            p_lookup_code     => null,
            x_lookup_code     => l_approval_type_code,
            x_return_status   => x_return_status
         );

      END IF;

      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      Igw_Prop_Special_Reviews_Pvt.Create_Prop_Special_Reviews
      (
         p_init_msg_list            => Fnd_Api.G_True,
         p_commit                   => Fnd_Api.G_False,
         p_validate_only            => p_validate_only,
         x_rowid                    => l_rowid,
         p_proposal_id              => l_proposal_id,
         p_proposal_number          => null,
         p_special_review_code      => l_special_review_code,
         p_special_review_desc      => p_special_review_desc,
         p_special_review_type      => l_special_review_type,
         p_special_review_type_desc => p_special_review_type_desc,
         p_approval_type_code       => l_approval_type_code,
         p_approval_type_desc       => p_approval_type_desc,
         p_protocol_number          => p_protocol_number,
         p_application_date         => p_application_date,
         p_approval_date            => p_approval_date,
         p_comments                 => p_comments,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data
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

         ROLLBACK TO Create_Prop_Special_Review_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Prop_Special_Review_Pub;

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

   END Create_Prop_Special_Review;

   ---------------------------------------------------------------------------

END Igw_Prop_Special_Reviews_Pub;

/
