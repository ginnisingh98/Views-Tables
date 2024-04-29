--------------------------------------------------------
--  DDL for Package IBU_MES_BIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_MES_BIN" 
/* $Header: ibuhmess.pls 115.5 2002/11/05 20:23:09 ktma ship $ */
AUTHID CURRENT_USER as

	    procedure get_bin_name (p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
				             p_bin_id       IN NUMBER,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
                     x_bin_name out NOCOPY VARCHAR2);

         procedure get_html (p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
				             p_bin_id			 IN   NUMBER,
				             p_cookie_url        In   VARCHAR2,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
                     x_clob      out NOCOPY CLOB);

	    procedure get_email_text (p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
				             p_user_id      IN NUMBER,
				             p_lang_code    IN VARCHAR2,
				             p_bin_id            IN   NUMBER,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
                     x_clob      out NOCOPY CLOB);

end ibu_mes_bin;

 

/
