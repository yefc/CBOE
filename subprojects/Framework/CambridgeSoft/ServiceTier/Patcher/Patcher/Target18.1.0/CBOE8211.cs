﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace CambridgeSoft.COE.Patcher
{
    class CBOE8211 : BugFixBaseCommand
    {
        public override List<string> Fix(List<XmlDocument> forms, List<XmlDocument> dataviews, List<XmlDocument> configurations, XmlDocument objectConfig, XmlDocument frameworkConfig)
        {
            List<string> messages = new List<string>();
            bool errorsInPatch = false;

            XmlNode databaseAttribute = frameworkConfig.SelectSingleNode("//coeHomeSettings/groups/add[@name='COE']/links/add[@name='TableEditor']");

            if (databaseAttribute != null)
            {
                if (databaseAttribute.Attributes["display"].Value == "Table Editor")
                {
                    databaseAttribute.RemoveAll();
                    messages.Add("TableEditor tag removed successfully");
                }
                else
                {
                    errorsInPatch = true;
                    messages.Add("TableEditor is not present");
                }
            }
            else
            {
                errorsInPatch = true;
                messages.Add("TableEditor node not available on COE");
            }


            if (!errorsInPatch && messages.Count != 0)
            {
                messages.Add("process succeed!");
            }
            else
            {
                messages.Add("failed to patch.");
            }

            return messages;
        }
    }
}


