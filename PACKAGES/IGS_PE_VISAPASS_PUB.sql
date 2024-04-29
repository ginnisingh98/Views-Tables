--------------------------------------------------------
--  DDL for Package IGS_PE_VISAPASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_VISAPASS_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPE16S.pls 120.1 2005/09/30 04:25:50 appldev noship $ */

/******************************************************************************
  ||  Created By : ssaleem
  ||  Created On : 01-Sep-2004
  ||  Purpose : This public API is used to update and insert records to
  ||            Visa, Passport and Visit Histry tables in IGS
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
******************************************************************************/

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE visa_rec_type IS RECORD(
               visa_id               igs_pe_visa.visa_id%TYPE,
               person_id             igs_pe_visa.person_id%TYPE,
               visa_type             igs_pe_visa.visa_type%TYPE,
               visa_number           igs_pe_visa.visa_number%TYPE,
               visa_issue_date       igs_pe_visa.visa_issue_date%TYPE,
               visa_expiry_date      igs_pe_visa.visa_expiry_date%TYPE,
               visa_issuing_post     igs_pe_visa.visa_issuing_post%TYPE,
               passport_id           igs_pe_visa.passport_id%TYPE,
               agent_org_unit_cd     igs_pe_visa.agent_org_unit_cd%TYPE,
               agent_person_id       igs_pe_visa.agent_person_id%TYPE,
               agent_contact_name    igs_pe_visa.agent_contact_name%TYPE,
               attribute_category    igs_pe_visa.attribute_category%TYPE,
               attribute1            igs_pe_visa.attribute1%TYPE,
               attribute2            igs_pe_visa.attribute2%TYPE,
               attribute3            igs_pe_visa.attribute3%TYPE,
               attribute4            igs_pe_visa.attribute4%TYPE,
               attribute5            igs_pe_visa.attribute5%TYPE,
               attribute6            igs_pe_visa.attribute6%TYPE,
               attribute7            igs_pe_visa.attribute7%TYPE,
               attribute8            igs_pe_visa.attribute8%TYPE,
               attribute9            igs_pe_visa.attribute9%TYPE,
               attribute10           igs_pe_visa.attribute10%TYPE,
               attribute11           igs_pe_visa.attribute11%TYPE,
               attribute12           igs_pe_visa.attribute12%TYPE,
               attribute13           igs_pe_visa.attribute13%TYPE,
               attribute14           igs_pe_visa.attribute14%TYPE,
               attribute15           igs_pe_visa.attribute15%TYPE,
               attribute16           igs_pe_visa.attribute16%TYPE,
               attribute17           igs_pe_visa.attribute17%TYPE,
               attribute18           igs_pe_visa.attribute18%TYPE,
               attribute19           igs_pe_visa.attribute19%TYPE,
               attribute20           igs_pe_visa.attribute20%TYPE,
               visa_issuing_country  igs_pe_visa.visa_issuing_country%TYPE
);

TYPE visit_hstry_rec_type IS RECORD(
               port_of_entry           igs_pe_visit_histry.port_of_entry%TYPE,
               cntry_entry_form_num   igs_pe_visit_histry.cntry_entry_form_num%TYPE,
               visa_id                igs_pe_visit_histry.visa_id%TYPE,
               visit_start_date       igs_pe_visit_histry.visit_start_date%TYPE,
               visit_end_date         igs_pe_visit_histry.visit_end_date%TYPE,
               remarks                igs_pe_visit_histry.remarks%TYPE
);

TYPE passport_rec_type IS RECORD(
               passport_id            igs_pe_passport.passport_id%TYPE,
               person_id              igs_pe_passport.person_id%TYPE,
               passport_number        igs_pe_passport.passport_number%TYPE,
               passport_expiry_date   igs_pe_passport.passport_expiry_date%TYPE,
               passport_cntry_code    igs_pe_passport.passport_cntry_code%TYPE
);


-- Start of comments
--        API name         : Create_Visa
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version              IN NUMBER        Required
--                                p_init_msg_list            IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                    IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visa_rec                  IN visa_rec_type
--
--
--        OUT              :      x_return_status             OUT        VARCHAR2(1)
--                                x_msg_count                 OUT        NUMBER
--                                x_msg_data                  OUT        VARCHAR2(2000)
--                                x_visa_id                   OUT     NUMBER
--
--
--
--        Version          : Current version        x.x
--                                Changed....
--                           previous version        y.y
--                                Changed....
--                           .
--                           .
--                          Initial version         1.0
--
--                          Notes                :
--
-- End of comments

PROCEDURE Create_Visa
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT   NOCOPY      VARCHAR2,
          x_msg_count                     OUT   NOCOPY      NUMBER,
          x_msg_data                      OUT   NOCOPY      VARCHAR2,
          p_visa_rec                      IN        visa_rec_type,
          x_visa_id                       OUT   NOCOPY      NUMBER
);


-- Start of comments
--        API name         : Update_Visa
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version              IN NUMBER        Required
--                                p_init_msg_list            IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                   IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visa_rec                 IN visa_rec_type
--
--
--        OUT                :    x_return_status            OUT        VARCHAR2(1)
--                                x_msg_count                OUT        NUMBER
--                                x_msg_data                 OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Update_Visa
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_visa_rec                      IN        visa_rec_type
);




-- Start of comments
--        API name         : Create_VisitHistry
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version                IN NUMBER        Required
--                                p_init_msg_list              IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                     IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visit_hstry_rec            IN visit_hstry_rec_type
--
--
--        OUT                :    x_return_status              OUT        VARCHAR2(1)
--                                x_msg_count                  OUT        NUMBER
--                                x_msg_data                   OUT        VARCHAR2(2000)
--
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Create_VisitHistry
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT   NOCOPY    VARCHAR2,
          x_msg_count                     OUT   NOCOPY    NUMBER,
          x_msg_data                      OUT   NOCOPY    VARCHAR2,
          p_visit_hstry_rec               IN        visit_hstry_rec_type
);


-- Start of comments
--        API name         : Update_VisitHistry
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version             IN NUMBER        Required
--                                p_init_msg_list           IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                  IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_visit_hstry_rec         IN        visit_hstry_rec_type
--
--
--        OUT                :    x_return_status           OUT        VARCHAR2(1)
--                                x_msg_count               OUT        NUMBER
--                                x_msg_data                OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Update_VisitHistry
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_visit_hstry_rec               IN        visit_hstry_rec_type
);


-- Start of comments
--        API name         : Create_Passport
--        Type             : Public
--        Function         :
--        Pre-reqs         : None.
--        Parameters       :
--        IN               :      p_api_version             IN NUMBER        Required
--                                p_init_msg_list           IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                  IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_passport_rec            IN passport_rec_type
--
--
--        OUT              :      x_return_status           OUT        VARCHAR2(1)
--                                x_msg_count               OUT        NUMBER
--                                x_msg_data                OUT        VARCHAR2(2000)
--                                x_passport_id             OUT     NUMBER
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Create_Passport
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_passport_rec                  IN        passport_rec_type,
          x_passport_id                   OUT  NOCOPY     NUMBER
);


-- Start of comments
--        API name         : Update_Passport
--        Type                : Public
--        Function        :
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version           IN NUMBER        Required
--                                p_init_msg_list            IN VARCHAR2         Optional
--                                Default = FND_API.G_FALSE
--                                p_commit                   IN VARCHAR2        Optional
--                                Default = FND_API.G_FALSE
--                                Default = FND_API.G_VALID_LEVEL_FULL
--                                p_passport_rec             IN passport_rec_type
--
--
--        OUT                :    x_return_status            OUT        VARCHAR2(1)
--                                x_msg_count                OUT        NUMBER
--                                x_msg_data                 OUT        VARCHAR2(2000)
--
--
--
--        Version        : Current version        x.x
--                                Changed....
--                          previous version        y.y
--                                Changed....
--                          .
--                          .
--                          Initial version         1.0
--
--        Notes                :
--
-- End of comments

PROCEDURE Update_Passport
(         p_api_version                   IN        NUMBER,
          p_init_msg_list                 IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_commit                        IN        VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY     VARCHAR2,
          x_msg_count                     OUT  NOCOPY     NUMBER,
          x_msg_data                      OUT  NOCOPY     VARCHAR2,
          p_passport_rec                  IN        passport_rec_type
);

END IGS_PE_VISAPASS_PUB;

 

/
