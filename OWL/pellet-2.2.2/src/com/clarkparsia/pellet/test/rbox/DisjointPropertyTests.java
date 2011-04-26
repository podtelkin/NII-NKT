// Copyright (c) 2006 - 2008, Clark & Parsia, LLC. <http://www.clarkparsia.com>
// This source code is available under the terms of the Affero General Public
// License v3.
//
// Please see LICENSE.txt for full license terms, including the availability of
// proprietary exceptions.
// Questions, comments, or requests for clarification: licensing@clarkparsia.com

package com.clarkparsia.pellet.test.rbox;

import static com.clarkparsia.pellet.utils.TermFactory.term;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import junit.framework.JUnit4TestAdapter;

import org.junit.Before;
import org.junit.Test;
import org.mindswap.pellet.KnowledgeBase;
import org.mindswap.pellet.test.PelletTestSuite;

import aterm.ATermAppl;

public class DisjointPropertyTests {
	public static String	base	= "file:" + PelletTestSuite.base + "misc/";

	private KnowledgeBase kb = null;
	
	private ATermAppl a = term( "a" );
	private ATermAppl b = term( "b" );
	private ATermAppl c = term( "c" );
	
	private ATermAppl p = term( "p" );
	private ATermAppl q = term( "q" );
	
	public static void main(String args[]) {
		junit.textui.TestRunner.run( DisjointPropertyTests.suite() );
	}

	public static junit.framework.Test suite() {
		return new JUnit4TestAdapter( DisjointPropertyTests.class );
	}

	@Before
	public void before() {
		kb = new KnowledgeBase();		
		
		kb.addObjectProperty( p );
		kb.addObjectProperty( q );

		kb.addIndividual( a );
		kb.addIndividual( b );
		kb.addIndividual( c );
				
		kb.addDisjointProperty( p, q );
	}
	
	@Test
	public void simpleInconcistency() {
		kb.addPropertyValue( p, a, b );
		kb.addPropertyValue( q, a, b );
		
		assertFalse( kb.isConsistent() );
	}
	
	@Test
	public void subPropertyInconcistency() {
		ATermAppl subP = term("subP");
		
		kb.addObjectProperty( subP );
		kb.addSubProperty( subP, p );
		
		kb.addPropertyValue( subP, a, b );
		kb.addPropertyValue( q, a, b );
		
		assertFalse( kb.isConsistent() );
	}
	
	@Test
	public void superPropertyConcistency() {
		ATermAppl supP = term("supP");
		
		kb.addObjectProperty( supP );
		kb.addSubProperty( p, supP );
		
		kb.addPropertyValue( supP, a, b );
		kb.addPropertyValue( q, b, b );
		
		assertTrue( kb.isConsistent() );
	}
	
	@Test
	public void invPropertyInconcistency() {
		ATermAppl invP = term("invP");
		
		kb.addObjectProperty( invP );
		kb.addInverseProperty( invP, p );
		
		kb.addPropertyValue( invP, b, a );
		kb.addPropertyValue( q, a, b );
		
		assertFalse( kb.isConsistent() );
	}	
	
	@Test
	public void differentFromSubjects() {
		kb.addPropertyValue( p, a, c );
		kb.addPropertyValue( q, b, c );
		
		assertTrue( kb.isDifferentFrom( a, b ) );
	}
	
	@Test
	public void differentFromObjects() {
		kb.addPropertyValue( p, a, b );
		kb.addPropertyValue( q, a, c );
		
		assertTrue( kb.isDifferentFrom( b, c ) );
	}
}
