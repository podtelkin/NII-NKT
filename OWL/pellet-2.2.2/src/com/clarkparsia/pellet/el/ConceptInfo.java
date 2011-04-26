// Copyright (c) 2006 - 2008, Clark & Parsia, LLC. <http://www.clarkparsia.com>
// This source code is available under the terms of the Affero General Public License v3.
//
// Please see LICENSE.txt for full license terms, including the availability of proprietary exceptions.
// Questions, comments, or requests for clarification: licensing@clarkparsia.com

package com.clarkparsia.pellet.el;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

import org.mindswap.pellet.utils.ATermUtils;
import org.mindswap.pellet.utils.MultiValueMap;

import aterm.ATermAppl;

import com.clarkparsia.pellet.utils.CollectionUtils;

/**
 * <p>
 * Title:
 * </p>
 * <p>
 * Description:
 * </p>
 * <p>
 * Copyright: Copyright (c) 2007
 * </p>
 * <p>
 * Company: Clark & Parsia, LLC. <http://www.clarkparsia.com>
 * </p>
 * 
 * @author Evren Sirin
 */
class ConceptInfo {
	public final static Logger						logger	= Logger.getLogger( ConceptInfo.class.getName() );

	private ATermAppl								concept;
	private Set<Trigger>							triggers;
	
	private MultiValueMap<ATermAppl, ConceptInfo>	successors;
	private MultiValueMap<ATermAppl, ConceptInfo>	predecessors;
	
	private Set<ConceptInfo>						superClasses;
	private List<ConceptInfo>						subClasses;

	public ConceptInfo(ATermAppl c, boolean storeSuccessors, boolean storeSubClasses ) {
		concept = c;
		
		superClasses = CollectionUtils.makeSet();
		subClasses = storeSubClasses
			? new ArrayList<ConceptInfo>()
			: null;

		successors = storeSuccessors
			 ? new MultiValueMap<ATermAppl, ConceptInfo>()
			 : null;
		predecessors = new MultiValueMap<ATermAppl, ConceptInfo>();
		
		triggers = storeSubClasses
			? null
			: new HashSet<Trigger>();
	}

	public boolean addSuccessor(ATermAppl p, ConceptInfo ci) {
		if( ci.predecessors.add( p, this ) ) {
			if( successors != null )
				successors.add( p, ci );
		
			return true;
		}

		return false;
	}

	public boolean addSuperClass(ConceptInfo sup) {
		return addSuperClass( sup, false );
	}
	
	public boolean addSuperClass(ConceptInfo sup, boolean indirect) {
		if( superClasses.add( sup ) ) {
			if( subClasses != null && !indirect ) {
				sup.subClasses.add( this );
			}
			
			return true;
		}

		return false;
	}

	public boolean addTrigger(Trigger trigger) {
		return triggers.add(trigger);
	}

	public boolean equals(Object obj) {
		return (obj instanceof ConceptInfo) && ((ConceptInfo) obj).concept == concept;
	}

	public ATermAppl getConcept() {
		return concept;
	}

	public MultiValueMap<ATermAppl, ConceptInfo> getSuccessors() {
		return successors;
	}

	public MultiValueMap<ATermAppl, ConceptInfo> getPredecessors() {
		return predecessors;
	}

	public Set<ConceptInfo> getSuperClasses() {
		return superClasses;
	}

	public Collection<ConceptInfo> getSubClasses() {
		return subClasses;
	}

	public Set<Trigger> getTriggers() {
		return triggers;
	}

	public boolean hasSuccessor(ATermAppl p, ConceptInfo ci) {
		return ci.predecessors.contains(p, this);
	}

	public int hashCode() {
		return concept.hashCode();
	}

	public boolean hasSuperClass(ConceptInfo ci) {
		return superClasses.contains( ci );
	}

	public String toString() {
		return ATermUtils.toString(concept);
	}
}