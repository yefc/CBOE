//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PerkinElmer.CBOE.Registration.Client.Model
{
    using System;
    using System.Collections.Generic;
    
    public partial class COMPOUND_FRAGMENT
    {
        public COMPOUND_FRAGMENT()
        {
            this.BATCHCOMPONENTFRAGMENTs = new HashSet<BATCHCOMPONENTFRAGMENT>();
        }
    
        public int ID { get; set; }
        public Nullable<int> COMPOUNDID { get; set; }
        public Nullable<int> FRAGMENTID { get; set; }
        public Nullable<decimal> EQUIVALENTS { get; set; }
    
        public virtual ICollection<BATCHCOMPONENTFRAGMENT> BATCHCOMPONENTFRAGMENTs { get; set; }
        public virtual FRAGMENT FRAGMENT { get; set; }
    }
}
